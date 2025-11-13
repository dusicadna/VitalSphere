import 'package:vital_sphere_desktop/model/asset.dart';
import 'package:vital_sphere_desktop/providers/base_provider.dart';

class AssetProvider extends BaseProvider<Asset> {
  AssetProvider() : super('Asset');

  @override
  Asset fromJson(dynamic json) {
    return Asset.fromJson(json as Map<String, dynamic>);
  }
}
