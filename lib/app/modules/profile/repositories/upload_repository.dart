import 'package:artverse/app/data/models/post_model.dart';
import 'package:artverse/app/modules/profile/providers/upload_provider.dart';

class UploadRepository {
  final UploadProvider _provider;
  UploadRepository(this._provider);

  Future<void> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
    required String contentType,
  }) async {
    final filename = path.split('/').last;
    await _provider.uploadToSupabase(
      bucket: bucket,
      path: path,
      bytes: bytes,
      contentType: contentType,
      filename: filename,
    );
  }

  String getFileUrl(String bucket, String path) {
    return _provider.getSupabasePublicUrl(bucket, path);
  }

  Future<void> publishPost(PostModel post) async {
    await _provider.savePostToSupabase(post.toJson());
  }
}
