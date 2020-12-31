import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo_riverpod/todo.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiverPod Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends HookWidget {
  Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todos = useProvider(filteredTodos);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              children: [
                // TODO: Title
                Title(),
                TextField(
                  controller: newTodoController,
                  decoration: const InputDecoration(
                    labelText: 'What needs to be done?',
                  ),
                  onSubmitted: (value) {
                    // TODO: on submitted
                    todoListProvider.read(context).add(value);
                    newTodoController.clear();
                  },
                ),
                const SizedBox(height: 42),
                Column(
                  children: [
                    // TODO: Toolbar
                    ToolBar(),
                    if (todos.isNotEmpty) const Divider(height: 0),
                    for (var i = 0; i < todos.length; i++) ...[
                      if (i > 0) const Divider(height: 0),
                      // dismissible allows you to swipe away an item to remove it
                      Dismissible(
                        key: ValueKey(todos[i].id),
                        onDismissed: (_) {
                          todoListProvider.read(context).remove(todos[i]);
                        },
                        child: TodoItem(todos[i]),
                      )
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToolBar extends HookWidget {
  const ToolBar({Key key}) : super(key: key);

  // TODO: implement ToolBar

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final filter = useProvider(todoListFilter);
    final search = useProvider(todoListSearch);

    Color textColorFor(TodoListFilter value) {
      return filter.state == value ? Colors.blue : null;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${useProvider(uncompletedTodosCount).toString()} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onChanged: (value) {
                search.state = value;
              },
            ),
          ),
          Tooltip(
            message: 'All todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.all,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.all),
              child: const Text('All'),
            ),
          ),
          Tooltip(
            message: 'Only uncompleted todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.active,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.active),
              child: const Text('Active'),
            ),
          ),
          Tooltip(
            message: 'Only completed todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.completed,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.completed),
              child: const Text('Completed'),
            ),
          ),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({Key key}) : super(key: key);

  // TODO: implement Title
  static const double _size = 86;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'todos',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: _size, fontWeight: FontWeight.w100),
        ),
        Icon(
          Icons.check,
          size: _size,
        ),
      ],
    );
  }
}

class TodoItem extends HookWidget {
  const TodoItem(this.todo, {Key key}) : super(key: key);
  final Todo todo;
  // TODO: implement TodoItem

  @override
  Widget build(BuildContext context) {
    final itemFocusNode = useFocusNode();
    useListenable(itemFocusNode);
    final isFocused = itemFocusNode.hasFocus;

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Material(
        color: Colors.white,
        elevation: 3,
        child: Focus(
          focusNode: itemFocusNode,
          onFocusChange: (focused) {
            if (focused) {
              textEditingController.text = todo.description;
            } else {
              //  Commit changes only when the text field is unfucused
              todoListProvider
                  .read(context)
                  .edit(id: todo.id, description: textEditingController.text);
            }
          },
          child: ListTile(
              onTap: () {
                itemFocusNode.requestFocus();
                textFieldFocusNode.requestFocus();
              },
              leading: Checkbox(
                value: todo.completed,
                onChanged: (value) =>
                    todoListProvider.read(context).toggle(todo.id),
              ),
              title: isFocused
                  ? TextField(
                      autofocus: true,
                      focusNode: textFieldFocusNode,
                      controller: textEditingController,
                    )
                  : Text(todo.description)),
        ),
      ),
    );
  }
}
