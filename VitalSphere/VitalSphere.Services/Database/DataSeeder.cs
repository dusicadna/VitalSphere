using VitalSphere.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace VitalSphere.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 00 000 000";

        private const string TestMailSender = "test.sender@gmail.com";
        private const string TestMailReceiver = "test.receiver@gmail.com";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role
                {
                    Id = 1,
                    Name = "Administrator",
                    Description = "System administrator with full access",
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new Role
                {
                    Id = 2,
                    Name = "User",
                    Description = "Regular user role",
                    CreatedAt = fixedDate,
                    IsActive = true
                }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    FirstName = "Adil",
                    LastName = "Joldić",
                    Email = TestMailReceiver,
                    Username = "admin",
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=",
                    PasswordSalt = "6raKZCuEsvnBBxPKHGpRtA==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")
                },
                new User
                {
                    Id = 2,
                    FirstName = "Adna",
                    LastName = "Dušić",
                    Email = "vitalsphere.receiver@gmail.com",
                    Username = "user",
                    PasswordHash = "kDPVcZaikiII7vXJbMEw6B0xZ245I29ocaxBjLaoAC0=",
                    PasswordSalt = "O5R9WmM6IPCCMci/BCG/eg==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, // Female
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adna.png")
                },
                new User
                {
                    Id = 3,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = "example2@gmail.com",
                    Username = "admin2",
                    PasswordHash = "BiWDuil9svAKOYzii5wopQW3YqjVfQrzGE2iwH/ylY4=",
                    PasswordSalt = "pfNS+OLBaQeGqBIzXXcWuA==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")
                },
                new User
                {
                    Id = 4,
                    FirstName = "Amel",
                    LastName = "Musić",
                    Email = TestMailSender,
                    Username = "user2",
                    PasswordHash = "KUF0Jsocq9AqdwR9JnT2OrAqm5gDj7ecQvNwh6fW/Bs=",
                    PasswordSalt = "c3ZKo0va3tYfnYuNKkHDbQ==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 1, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "amel.png")
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = fixedDate },
                new UserRole { Id = 2, UserId = 2, RoleId = 2, DateAssigned = fixedDate },
                new UserRole { Id = 3, UserId = 3, RoleId = 1, DateAssigned = fixedDate },
                new UserRole { Id = 4, UserId = 4, RoleId = 2, DateAssigned = fixedDate }
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo" },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla" },
                new City { Id = 4, Name = "Zenica" },
                new City { Id = 5, Name = "Mostar" },
                new City { Id = 6, Name = "Bijeljina" },
                new City { Id = 7, Name = "Prijedor" },
                new City { Id = 8, Name = "Brčko" },
                new City { Id = 9, Name = "Doboj" },
                new City { Id = 10, Name = "Zvornik" },
                new City { Id = 11, Name = "Cazin" },
                new City { Id = 12, Name = "Bihać" },
                new City { Id = 13, Name = "Velika Kladuša" },
                new City { Id = 14, Name = "Sanski Most" },
                new City { Id = 15, Name = "Bugojno" },
                new City { Id = 16, Name = "Travnik" },
                new City { Id = 17, Name = "Jajce" },
                new City { Id = 18, Name = "Goražde" },
                new City { Id = 19, Name = "Konjic" },
                new City { Id = 20, Name = "Livno" },
                new City { Id = 21, Name = "Trebinje" },
                new City { Id = 22, Name = "Foča" },
                new City { Id = 23, Name = "Srebrenik" },
                new City { Id = 24, Name = "Gradačac" },
                new City { Id = 25, Name = "Lukavac" },
                new City { Id = 26, Name = "Kakanj" },
                new City { Id = 27, Name = "Visoko" },
                new City { Id = 28, Name = "Čapljina" },
                new City { Id = 29, Name = "Neum" },
                new City { Id = 30, Name = "Široki Brijeg" }
            );


            // Seed Wellness Service Categories
            modelBuilder.Entity<WellnessServiceCategory>().HasData(
    new WellnessServiceCategory
    {
        Id = 1,
        Name = "Body & Fitness",
        Description = "Focus on building strength, flexibility, and overall physical wellness through guided workouts, personalized training, and fitness programs designed for all levels.",
        Image = ImageConversion.ConvertImageToByteArray("Assets", "wsc1.png"),
        CreatedAt = fixedDate,
        IsActive = true
    },
    new WellnessServiceCategory
    {
        Id = 2,
        Name = "Massage & Relaxation",
        Description = "Restore balance and relieve tension with a variety of therapeutic massages and relaxation techniques aimed at reducing stress and revitalizing your body and mind.",
        Image = ImageConversion.ConvertImageToByteArray("Assets", "wsc2.png"),
        CreatedAt = fixedDate,
        IsActive = true
    },
    new WellnessServiceCategory
    {
        Id = 3,
        Name = "Mind & Balance",
        Description = "Achieve inner peace and mental clarity through yoga, meditation, and mindfulness practices designed to harmonize your body, mind, and spirit.",
        Image = ImageConversion.ConvertImageToByteArray("Assets", "wsc3.png"),
        CreatedAt = fixedDate,
        IsActive = true
    },
    new WellnessServiceCategory
    {
        Id = 4,
        Name = "Hydro & Thermal",
        Description = "Experience the soothing power of water and heat with our sauna, steam, and pool therapies that promote detoxification, relaxation, and rejuvenation.",
        Image = ImageConversion.ConvertImageToByteArray("Assets", "wsc4.png"),
        CreatedAt = fixedDate,
        IsActive = true
    }
        );


            // Seed Wellness Services
            modelBuilder.Entity<WellnessService>().HasData(
                // 🧘‍♀️ Body & Fitness
                new WellnessService
                {
                    Id = 1,
                    Name = "Personal Training",
                    Description = "One-on-one customized fitness sessions focused on achieving your individual health and strength goals with professional guidance.",
                    Price = 60,
                    DurationMinutes = 60,
                    WellnessServiceCategoryId = 1,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws1.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessService
                {
                    Id = 2,
                    Name = "Pilates Class",
                    Description = "Low-impact sessions that improve flexibility, posture, and core strength through controlled movement and breathing techniques.",
                    Price = 50,
                    DurationMinutes = 60,
                    WellnessServiceCategoryId = 1,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws2.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },

                // 🌿 Massage & Relaxation
                new WellnessService
                {
                    Id = 3,
                    Name = "Aromatherapy Massage",
                    Description = "A calming massage experience using essential oils to reduce stress, ease tension, and improve emotional well-being.",
                    Price = 80,
                    DurationMinutes = 60,
                    WellnessServiceCategoryId = 2,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws3.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessService
                {
                    Id = 4,
                    Name = "Deep Tissue Massage",
                    Description = "Therapeutic massage focused on deeper layers of muscle and connective tissue to relieve chronic pain and stiffness.",
                    Price = 100,
                    DurationMinutes = 60,
                    WellnessServiceCategoryId = 2,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws4.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },

                // 🧠 Mind & Balance
                new WellnessService
                {
                    Id = 5,
                    Name = "Yoga Session",
                    Description = "Guided yoga practice combining physical postures, breathing exercises, and mindfulness for total body and mind harmony.",
                    Price = 50,
                    DurationMinutes = 60,
                    WellnessServiceCategoryId = 3,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws5.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessService
                {
                    Id = 6,
                    Name = "Meditation Class",
                    Description = "Calming guided meditation sessions to enhance focus, relieve stress, and promote emotional balance and awareness.",
                    Price = 40,
                    DurationMinutes = 60,
                    WellnessServiceCategoryId = 3,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws6.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },

                // 💧 Hydro & Thermal
                new WellnessService
                {
                    Id = 7,
                    Name = "Sauna Session",
                    Description = "Relaxing heat therapy that promotes detoxification, muscle recovery, and improved circulation through dry or steam sauna environments.",
                    Price = 30,
                    DurationMinutes = 90,
                    WellnessServiceCategoryId = 4,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws7.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessService
                {
                    Id = 8,
                    Name = "Pool & Hydrotherapy",
                    Description = "Invigorating pool-based relaxation and gentle water exercises that improve mobility, tone muscles, and calm the mind.",
                    Price = 40,
                    DurationMinutes = 160,
                    WellnessServiceCategoryId = 4,
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "ws8.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                }
            );


            // Seed Wellness Boxes
            modelBuilder.Entity<WellnessBox>().HasData(
                new WellnessBox
                {
                    Id = 1,
                    Name = "Welcome Wellness Box",
                    Description = "A special starter kit given to all new clients when they schedule their first wellness service — a gentle introduction to relaxation and self-care.",
                    IncludedItems = "Herbal tea blend, Relaxation eye mask, Mini essential oil (lavender), Welcome card with wellness tips",
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "wb1.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessBox
                {
                    Id = 2,
                    Name = "Relax & Restore Box",
                    Description = "A soothing box designed to help you unwind and recover after your massage or sauna session.",
                    IncludedItems = "Scented candle, Bath salts, Body lotion, Herbal relaxation pillow",
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "wb2.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessBox
                {
                    Id = 3,
                    Name = "Active Body Box",
                    Description = "An energizing set for fitness lovers — perfect for recovery and motivation after active sessions.",
                    IncludedItems = "Protein snack, Resistance band, Cooling towel, Mini muscle balm",
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "wb3.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                },
                new WellnessBox
                {
                    Id = 4,
                    Name = "Mind & Balance Box",
                    Description = "A calming box that encourages mindfulness and balance through reflection and relaxation.",
                    IncludedItems = "Gratitude journal, Meditation candle, Incense sticks, Affirmation cards",
                    Image = ImageConversion.ConvertImageToByteArray("Assets", "wb4.png"),
                    CreatedAt = fixedDate,
                    IsActive = true
                }
            );


            // Seed Brands
            modelBuilder.Entity<Brand>().HasData(
                new Brand
                {
                    Id = 1,
                    Name = "AuraHome",
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new Brand
                {
                    Id = 2,
                    Name = "PureZen Naturals",
                    IsActive = true,
                    CreatedAt = fixedDate
                },

                new Brand
                {
                    Id = 3,
                    Name = "CalmRoots",
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new Brand
                {
                    Id = 4,
                    Name = "GlowVita",
                    IsActive = true,
                    CreatedAt = fixedDate
                }

            );

            // Seed Product Categories
            modelBuilder.Entity<ProductCategory>().HasData(
                new ProductCategory
                {
                    Id = 1,
                    Name = "Aromatherapy",
                    Description = "Aromatherapy is the use of essential oils to promote physical and mental well-being.",
                    IsActive = true,
                },
                new ProductCategory
                {
                    Id = 2,
                    Name = "Body Care",
                    Description = "Body care is the practice of taking care of the body to maintain its health and appearance.",
                    IsActive = true,
                },
                new ProductCategory
                {
                    Id = 3,
                    Name = "Essential Oils",
                    Description = "Essential oils are concentrated liquids derived from plants that are used for their therapeutic properties.",
                    IsActive = true,
                },
                new ProductCategory
                {
                    Id = 4,
                    Name = "Skincare",
                    Description = "Skincare is the practice of taking care of the skin to maintain its health and appearance.",
                    IsActive = true,
                }
            );

            // Seed Products
            modelBuilder.Entity<Product>().HasData(
                new Product
                {
                    Id = 1,
                    Name = "Serenity Soy Candle",
                    Price = 5,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    ProductCategoryId = 1,
                    BrandId = 1,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "p1.png")
                },
                new Product
                {
                    Id = 2,
                    Name = "Himalayan Bath Salt Blend",
                    Price = 15,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    ProductCategoryId = 2,
                    BrandId = 2,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "p2.png")
                },
                new Product
                {
                    Id = 3,
                    Name = "Revitalize Essential Oil Roller",
                    Price = 30,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    ProductCategoryId = 3,
                    BrandId = 3,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "p3.png")
                },
                new Product
                {
                    Id = 4,
                    Name = "Deep Hydration Face Mask",
                    Price = 25,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    ProductCategoryId = 4,
                    BrandId = 4,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "p4.png")
                }
            );

            // Seed Appointments
            modelBuilder.Entity<Appointment>().HasData(
                new Appointment
                {
                    Id = 1,
                    UserId = 2, // Adna
                    WellnessServiceId = 3, // Aromatherapy Massage
                    ScheduledAt = fixedDate.AddDays(-60).AddHours(10),
                    Notes = "Relaxation session after a busy week.",
                    CreatedAt = fixedDate.AddDays(-20)
                },
                new Appointment
                {
                    Id = 2,
                    UserId = 2, // Adna
                    WellnessServiceId = 5, // Yoga Session
                    ScheduledAt = fixedDate.AddDays(-70).AddHours(8),
                    Notes = "Morning session to improve flexibility.",
                    CreatedAt = fixedDate.AddDays(-10)
                },
                new Appointment
                {
                    Id = 3,
                    UserId = 2, // Adna
                    WellnessServiceId = 2, // Pilates Class
                    ScheduledAt = fixedDate.AddDays(30).AddHours(9),
                    Notes = "Upcoming pilates class to maintain progress.",
                    CreatedAt = fixedDate
                }
            );

            // Seed Reviews for Adna's past appointments
            modelBuilder.Entity<Review>().HasData(
                new Review
                {
                    Id = 1,
                    UserId = 2, // Adna
                    AppointmentId = 1,
                    Rating = 5,
                    Comment = "Absolutely loved the aromatherapy massage! Felt rejuvenated.",
                    CreatedAt = fixedDate.AddDays(-70)
                },
                new Review
                {
                    Id = 2,
                    UserId = 2, // Adna
                    AppointmentId = 2,
                    Rating = 4,
                    Comment = "Great yoga session with helpful guidance throughout.",
                    CreatedAt = fixedDate.AddDays(-60)
                }
            );

            // Seed Order for Adna
            modelBuilder.Entity<Order>().HasData(
                new Order
                {
                    Id = 1,
                    UserId = 2, // Adna
                    TotalAmount = 35m,
                    CreatedAt = fixedDate,
                    IsActive = true
                }
            );

            // Seed Order Items for Adna's order
            modelBuilder.Entity<OrderItem>().HasData(
                new OrderItem
                {
                    Id = 1,
                    OrderId = 1,
                    ProductId = 1, // Serenity Soy Candle
                    Quantity = 2,
                    UnitPrice = 5m,
                    TotalPrice = 10m,
                    CreatedAt = fixedDate
                },
                new OrderItem
                {
                    Id = 2,
                    OrderId = 1,
                    ProductId = 4, // Deep Hydration Face Mask
                    Quantity = 1,
                    UnitPrice = 25m,
                    TotalPrice = 25m,
                    CreatedAt = fixedDate
                }
            );

            // Seed Gift Statuses
            modelBuilder.Entity<GiftStatus>().HasData(
                new GiftStatus
                {
                    Id = 1,
                    Name = "Earned",
                    Description = "Gift earned by the user."
                },
                new GiftStatus
                {
                    Id = 2,
                    Name = "Picked Up",
                    Description = "Gift collected at the wellness center."
                }
            );

            // Seed Gifts for Adna
            modelBuilder.Entity<Gift>().HasData(
                new Gift
                {
                    Id = 1,
                    UserId = 2, // Adna
                    WellnessBoxId = 1,
                    GiftStatusId = 2,
                    GiftedAt = fixedDate.AddDays(-20)
                    
                }
            );

         
    }
    }
}