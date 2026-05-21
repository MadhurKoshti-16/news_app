import '../entities/article_entity.dart';
import '../repositories/news_repository.dart';
import '../../../../core/error/failures.dart';

class GetBookmarksUseCase {
  const GetBookmarksUseCase(this._repository);
  final NewsRepository _repository;

  Future<({Failure? failure, List<ArticleEntity>? data})> call() {
    return _repository.getBookmarks();
  }
}

class AddBookmarkUseCase {
  const AddBookmarkUseCase(this._repository);
  final NewsRepository _repository;

  Future<({Failure? failure, void data})> call(ArticleEntity article) {
    return _repository.addBookmark(article);
  }
}

class RemoveBookmarkUseCase {
  const RemoveBookmarkUseCase(this._repository);
  final NewsRepository _repository;

  Future<({Failure? failure, void data})> call(String articleId) {
    return _repository.removeBookmark(articleId);
  }
}
