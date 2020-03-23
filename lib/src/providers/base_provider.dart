import '../models/customer.dart';

abstract class BaseProvider {
  Future<int> delete(int id);

  Future<Customer> selectSingle(int id);

  Future<List<Customer>> select({String searchQuery});

  Future<Customer> insert(Customer customer);

  Future<void> open(String path);

  Future<int> update(Customer customer);
}
