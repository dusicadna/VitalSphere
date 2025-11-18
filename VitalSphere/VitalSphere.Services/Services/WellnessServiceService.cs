using VitalSphere.Model.Requests;
using VitalSphere.Model.Responses;
using VitalSphere.Model.SearchObjects;
using VitalSphere.Services.Database;
using VitalSphere.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace VitalSphere.Services.Services
{
    public class WellnessServiceService : BaseCRUDService<WellnessServiceResponse, WellnessServiceSearchObject, WellnessService, WellnessServiceUpsertRequest, WellnessServiceUpsertRequest>, IWellnessServiceService
    {
        private static MLContext _mlContext = null;
        private static object _mlLock = new object();
        private static ITransformer? _model = null;

        public WellnessServiceService(VitalSphereDbContext context, IMapper mapper) : base(context, mapper)
        {
            if (_mlContext == null)
            {
                lock (_mlLock)
                {
                    if (_mlContext == null)
                    {
                        _mlContext = new MLContext();
                    }
                }
            }
        }

        protected override IQueryable<WellnessService> ApplyFilter(IQueryable<WellnessService> query, WellnessServiceSearchObject search)
        {
            query = query.Include(ws => ws.WellnessServiceCategory);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(ws => ws.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(ws => ws.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(ws => ws.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(ws => ws.IsActive == search.IsActive.Value);
            }

            if (search.WellnessServiceCategoryId.HasValue)
            {
                query = query.Where(ws => ws.WellnessServiceCategoryId == search.WellnessServiceCategoryId.Value);
            }

            return query;
        }

        public override async Task<WellnessServiceResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.WellnessServices
                .Include(ws => ws.WellnessServiceCategory)
                .FirstOrDefaultAsync(ws => ws.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override WellnessServiceResponse MapToResponse(WellnessService entity)
        {
            var response = base.MapToResponse(entity);
            response.WellnessServiceCategoryId = entity.WellnessServiceCategoryId;
            response.WellnessServiceCategoryName = entity.WellnessServiceCategory?.Name ?? string.Empty;
            return response;
        }

        protected override async Task BeforeInsert(WellnessService entity, WellnessServiceUpsertRequest request)
        {
            if (await _context.WellnessServices.AnyAsync(ws => ws.Name == request.Name))
            {
                throw new InvalidOperationException("A wellness service with this name already exists.");
            }

            if (!await _context.WellnessServiceCategories.AnyAsync(c => c.Id == request.WellnessServiceCategoryId))
            {
                throw new InvalidOperationException("The specified wellness service category does not exist.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(WellnessService entity, WellnessServiceUpsertRequest request)
        {
            if (await _context.WellnessServices.AnyAsync(ws => ws.Name == request.Name && ws.Id != entity.Id))
            {
                throw new InvalidOperationException("A wellness service with this name already exists.");
            }

            if (!await _context.WellnessServiceCategories.AnyAsync(c => c.Id == request.WellnessServiceCategoryId))
            {
                throw new InvalidOperationException("The specified wellness service category does not exist.");
            }
        }

        // Train a simple recommender using Matrix Factorization on (User, WellnessService) implicit feedback
        public static void TrainRecommenderAtStartup(IServiceProvider serviceProvider)
        {
            lock (_mlLock)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();
                }
                using var scope = serviceProvider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<VitalSphereDbContext>();

                // Build implicit feedback dataset combining appointments and positive reviews
                var positiveEntries =
                    db.Appointments.Select(a => new FeedbackEntry
                    {
                        UserId = (uint)a.UserId,
                        WellnessServiceId = (uint)a.WellnessServiceId,
                        Label = 1f
                    }).ToList();

                var positiveReviewEntries = db.Reviews
                    .Where(r => r.Rating >= 4)
                    .Include(r => r.Appointment)
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        WellnessServiceId = (uint)r.Appointment.WellnessServiceId,
                        Label = 1.5f // Higher weight for highly rated services
                    }).ToList();

                positiveEntries.AddRange(positiveReviewEntries);

                if (!positiveEntries.Any())
                {
                    _model = null;
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(positiveEntries);
                var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.WellnessServiceId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 50,
                    C = 0.00001
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        public WellnessServiceResponse RecommendForUser(int userId)
        {
            if (_model == null)
            {
                // Fallback: recommend using heuristic approach
                return RecommendHeuristic(userId);
            }

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, WellnessServiceScorePrediction>(_model);

            var usedServiceIds = _context.Appointments
                .Where(a => a.UserId == userId)
                .Select(a => a.WellnessServiceId)
                .Distinct()
                .ToHashSet();

            // Get categories from services user has used
            var usedCategoryIds = _context.WellnessServices
                .Where(ws => usedServiceIds.Contains(ws.Id))
                .Select(ws => ws.WellnessServiceCategoryId)
                .Distinct()
                .ToHashSet();

            // Get categories from highly rated services
            var highlyRatedServiceIds = _context.Reviews
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Include(r => r.Appointment)
                .Select(r => r.Appointment.WellnessServiceId)
                .Distinct()
                .ToList();

            var likedCategoryIds = _context.WellnessServices
                .Where(ws => highlyRatedServiceIds.Contains(ws.Id))
                .Select(ws => ws.WellnessServiceCategoryId)
                .Distinct()
                .ToHashSet();

            // Combine used and liked categories
            var preferredCategoryIds = usedCategoryIds.Union(likedCategoryIds).ToHashSet();

            // Prioritize services from preferred categories that user hasn't used
            var candidateServices = _context.WellnessServices
                .Include(ws => ws.WellnessServiceCategory)
                .Where(ws => ws.IsActive && !usedServiceIds.Contains(ws.Id))
                .ToList();

            if (!candidateServices.Any())
            {
                // If all services have been used, include them but still prioritize preferred categories
                candidateServices = _context.WellnessServices
                    .Include(ws => ws.WellnessServiceCategory)
                    .Where(ws => ws.IsActive)
                    .ToList();
            }

            if (!candidateServices.Any())
            {
                return RecommendHeuristic(userId);
            }

            // Score all candidates and apply category boost
            var scored = candidateServices
                .Select(ws => new
                {
                    WellnessService = ws,
                    MLScore = predictionEngine.Predict(new FeedbackEntry
                    {
                        UserId = (uint)userId,
                        WellnessServiceId = (uint)ws.Id
                    }).Score,
                    // Boost score if service is from a preferred category
                    CategoryBoost = preferredCategoryIds.Contains(ws.WellnessServiceCategoryId) ? 0.5f : 0f
                })
                .Select(x => new
                {
                    x.WellnessService,
                    FinalScore = x.MLScore + x.CategoryBoost
                })
                .OrderByDescending(x => x.FinalScore)
                .First().WellnessService;

            return MapToResponse(scored);
        }

        private WellnessServiceResponse RecommendHeuristic(int userId)
        {
            // Get services the user has used (via appointments)
            var usedServiceIds = _context.Appointments
                .Where(a => a.UserId == userId)
                .Select(a => a.WellnessServiceId)
                .Distinct()
                .ToHashSet();

            // Get highly rated services (rating >= 4) from user's reviews
            var highlyRatedServiceIds = _context.Reviews
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Include(r => r.Appointment)
                .Select(r => r.Appointment.WellnessServiceId)
                .Distinct()
                .ToList();

            // Get categories from highly rated services
            var likedCategoryIds = _context.WellnessServices
                .Where(ws => highlyRatedServiceIds.Contains(ws.Id))
                .Select(ws => ws.WellnessServiceCategoryId)
                .Distinct()
                .ToList();

            // If user has no reviews, get categories from their appointments
            if (!likedCategoryIds.Any() && usedServiceIds.Any())
            {
                likedCategoryIds = _context.WellnessServices
                    .Where(ws => usedServiceIds.Contains(ws.Id))
                    .Select(ws => ws.WellnessServiceCategoryId)
                    .Distinct()
                    .ToList();
            }

            // If still no categories, return a random active service
            if (!likedCategoryIds.Any())
            {
                var activeServices = _context.WellnessServices
                    .Include(ws => ws.WellnessServiceCategory)
                    .Where(ws => ws.IsActive)
                    .ToList();
                
                if (!activeServices.Any())
                    throw new InvalidOperationException("No wellness services available for recommendation.");

                var random = new Random();
                var randomService = activeServices[random.Next(activeServices.Count)];

                return MapToResponse(randomService);
            }

            // Find services in liked categories
            // Prioritize services user hasn't used, but can also recommend used ones
            var candidateServices = _context.WellnessServices
                .Include(ws => ws.WellnessServiceCategory)
                .Where(ws => ws.IsActive && likedCategoryIds.Contains(ws.WellnessServiceCategoryId))
                .ToList();

            if (!candidateServices.Any())
            {
                // Fallback: any active service
                var activeServices = _context.WellnessServices
                    .Include(ws => ws.WellnessServiceCategory)
                    .Where(ws => ws.IsActive)
                    .ToList();

                if (!activeServices.Any())
                    throw new InvalidOperationException("No wellness services available for recommendation.");

                var random = new Random();
                var fallbackService = activeServices[random.Next(activeServices.Count)];

                return MapToResponse(fallbackService);
            }

            // Prioritize services user hasn't used
            var newServices = candidateServices
                .Where(ws => !usedServiceIds.Contains(ws.Id))
                .ToList();

            WellnessService? recommendedService;

            if (newServices.Any())
            {
                // If there are new services, pick one from highly rated categories
                var newServicesInLikedCategories = newServices
                    .Where(ws => likedCategoryIds.Contains(ws.WellnessServiceCategoryId))
                    .ToList();

                var random = new Random();
                if (newServicesInLikedCategories.Any())
                {
                    recommendedService = newServicesInLikedCategories[random.Next(newServicesInLikedCategories.Count)];
                }
                else
                {
                    recommendedService = newServices[random.Next(newServices.Count)];
                }
            }
            else
            {
                // All services have been used, recommend one from liked categories
                var usedServicesInLikedCategories = candidateServices
                    .Where(ws => likedCategoryIds.Contains(ws.WellnessServiceCategoryId))
                    .ToList();

                var random = new Random();
                if (usedServicesInLikedCategories.Any())
                {
                    recommendedService = usedServicesInLikedCategories[random.Next(usedServicesInLikedCategories.Count)];
                }
                else
                {
                    recommendedService = candidateServices[random.Next(candidateServices.Count)];
                }
            }

            return MapToResponse(recommendedService);
        }

        private class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }
            [KeyType(count: 100000)]
            public uint WellnessServiceId { get; set; }
            public float Label { get; set; }
        }

        private class WellnessServiceScorePrediction
        {
            public float Score { get; set; }
        }
    }
}

