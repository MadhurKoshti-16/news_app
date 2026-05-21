import '../entities/article_entity.dart';
import '../repositories/news_repository.dart';
import '../../../../core/error/failures.dart';

class GetTopHeadlinesUseCase {
  const GetTopHeadlinesUseCase(this._repository);

  final NewsRepository _repository;

  Future<({Failure? failure, List<ArticleEntity>? data})> call({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) {
    return _repository.getTopHeadlines(
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }
}
