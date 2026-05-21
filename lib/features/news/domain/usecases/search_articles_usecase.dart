import '../entities/article_entity.dart';
import '../repositories/news_repository.dart';
import '../../../../core/error/failures.dart';

class SearchArticlesUseCase {
  const SearchArticlesUseCase(this._repository);

  final NewsRepository _repository;

  Future<({Failure? failure, List<ArticleEntity>? data})> call({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) {
    return _repository.searchArticles(
      query: query,
      page: page,
      pageSize: pageSize,
    );
  }
}
