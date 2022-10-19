import 'package:flutter/foundation.dart';
import 'package:memogenerator/data/repositories/list_reactive_repository.dart';
import 'package:collection/collection.dart';

abstract class ListWithIdsReactiveRepository<T>
    extends ListReactiveRepository<T> {

  @protected
  dynamic getId(final T item);

  //Метод добавления в избраное
  Future<bool> addItemOrReplaceById(final T newItem) async {
// Если лист пустой
    final items = await getItems();
    final itemIndex = items.indexWhere((item) => getId(item) == getId(newItem));
    if (itemIndex == -1) {
      items.add(newItem);
    } else {
      items[itemIndex] = newItem;
    }
    return setItems(items);
  }

//Метод удаления из избранного
  Future<bool> removeFromItemsById(final dynamic id) async {
// Если лист пустой
    final items = await getItems();
    items.removeWhere((item) => getId(item) == id);
    return setItems(items);
  }

//Метод оффлайн просмотра избранного
  Future<T?> getItemById(final dynamic id) async {
    final items = await getItems();
    return items.firstWhereOrNull((item) => getId(item) == id);
  }
}