abstract class BaseProvider<T> {
  Future<int> delete(int id);

  Future<T> selectSingle(int id);

  Future<List<T>> select({String searchQuery});

  Future<T> insert(T item);

  Future<void> open(String path);

  Future<int> update(T item);
}
