import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';

var _uuid = Uuid();

///
/// A read-only description of a todo-item
///
class Todo {
  Todo({
    this.description,
    this.completed = false,
    String id,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

class TodoList extends StateNotifier<List<Todo>> {
  TodoList([List<Todo> initialTodos]) : super(initialTodos ?? []);

  void add(String description) {
    // Use the spread operation to unpack the current state and create a new list
    // to set a new state with the new Todo task
    state = [
      ...state,
      Todo(description: description),
    ];
  }

  void toggle(String id) {
    // Loop through state and toggle the completed flag and stuff into state
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: !todo.completed,
            description: todo.description,
          )
        else
          todo,
    ];
  }

  void edit({@required String id, @required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: todo.completed,
            description: description,
          )
        else
          todo,
    ];
  }

  void remove(Todo target) {
    // create a new list without the target id
    state = state.where((todo) => todo.id != target.id).toList();
  }
}

/// Creates a [TodoList] and initialize it with pre-defined values.
///
/// We are using [StateNotifierProvider] here as a `List<Todo>` is a complex
/// object, with advanced business logic like how to edit a todo.
final todoListProvider = StateNotifierProvider<TodoList>((_) {
  return TodoList([
    Todo(id: 'todo-0', description: 'hi'),
    Todo(id: 'todo-1', description: 'hello'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ]);
});

/// The different ways to filter the list of todos
enum TodoListFilter {
  all,
  active,
  completed,
}

/// The currently active filter.final
///
/// We use [StateProvider] here as there is no fancy logic behind manipulating
/// the value since it's just an enum.
///
final todoListFilter = StateProvider((_) => TodoListFilter.all);

/// The current active search
final todoListSearch = StateProvider((_) => '');

final uncompletedTodosCount = Computed((read) {
  return read(todoListProvider.state).where((todo) => !todo.completed).length;
});

final filteredTodos = Computed<List<Todo>>((read) {
  final filter = read(todoListFilter);
  final search = read(todoListSearch);
  final todos = read(todoListProvider.state);

  List<Todo> filteredTodos;

  switch (filter.state) {
    case TodoListFilter.completed:
      filteredTodos = todos.where((todo) => todo.completed).toList();
      break;
    case TodoListFilter.active:
      filteredTodos = todos.where((todo) => !todo.completed).toList();
      break;
    case TodoListFilter.all:
    default:
      filteredTodos = todos;
      break;
  }

  if (search.state.isEmpty) {
    return filteredTodos;
  } else {
    return filteredTodos
        .where((todo) => todo.description.contains(search.state))
        .toList();
  }
});

final todoCompletedFilter = StateProvider((_) => TodoListFilter.completed);
