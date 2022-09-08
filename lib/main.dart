import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Person {
  Person({required this.id, required this.name, required this.age});

  final String id;
  final String name;
  final int age;
}

class Family {
  Family({required this.id, required this.name, required this.people});

  final String id;
  final String name;
  final List<Person> people;

  Person person(String pid) => people.singleWhere(
        (p) => p.id == pid,
        orElse: () => throw Exception('unknown person $pid for family $id'),
      );
}

class Families {
  static final data = [
    Family(
      id: 'f1',
      name: 'Sells',
      people: [
        Person(id: 'p1', name: 'Chris', age: 52),
        Person(id: 'p2', name: 'John', age: 27),
        Person(id: 'p3', name: 'Tom', age: 26),
      ],
    ),
    Family(
      id: 'f2',
      name: 'Addams',
      people: [
        Person(id: 'p1', name: 'Gomez', age: 55),
        Person(id: 'p2', name: 'Morticia', age: 50),
        Person(id: 'p3', name: 'Pugsley', age: 10),
        Person(id: 'p4', name: 'Wednesday', age: 17),
      ],
    ),
    Family(
      id: 'f3',
      name: 'Hunting',
      people: [
        Person(id: 'p1', name: 'Mom', age: 54),
        Person(id: 'p2', name: 'Dad', age: 55),
        Person(id: 'p3', name: 'Will', age: 20),
        Person(id: 'p4', name: 'Marky', age: 21),
        Person(id: 'p5', name: 'Ricky', age: 22),
        Person(id: 'p6', name: 'Danny', age: 23),
        Person(id: 'p7', name: 'Terry', age: 24),
        Person(id: 'p8', name: 'Mikey', age: 25),
        Person(id: 'p9', name: 'Davey', age: 26),
        Person(id: 'p10', name: 'Timmy', age: 27),
        Person(id: 'p11', name: 'Tommy', age: 28),
        Person(id: 'p12', name: 'Joey', age: 29),
        Person(id: 'p13', name: 'Robby', age: 30),
        Person(id: 'p14', name: 'Johnny', age: 31),
        Person(id: 'p15', name: 'Brian', age: 32),
      ],
    ),
  ];

  static Family family(String fid) => data.family(fid);
}

extension on List<Family> {
  Family family(String fid) => singleWhere(
        (f) => f.id == fid,
        orElse: () => throw Exception('unknown family $fid'),
      );
}

class LoginInfo extends ChangeNotifier {
  var _userName = '';
  String get userName => _userName;
  bool get loggedIn => _userName.isNotEmpty;

  void login(String userName) {
    _userName = userName;
    notifyListeners();
  }

  void logout() {
    _userName = '';
    notifyListeners();
  }
}

class LoginInfo2 extends ChangeNotifier {
  var _userName = '';
  String get userName => _userName;
  bool get loggedIn => _userName.isNotEmpty;

  Future<void> login(String userName) async {
    _userName = userName;
    notifyListeners();
    await Future<void>.delayed(const Duration(microseconds: 2500));
  }

  Future<void> logout() async {
    _userName = '';
    notifyListeners();
    await Future<void>.delayed(const Duration(microseconds: 2500));
  }
}

class FamilyPerson {
  FamilyPerson({required this.family, required this.person});

  final Family family;
  final Person person;
}

class Repository {
  static final rnd = Random();

  Future<List<Family>> getFamilies() async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate error
    // if (rnd.nextBool()) throw Exception('error fetching families');

    // return data "fetched over the network"
    return Families.data;
  }

  Future<Family> getFamily(String fid) async =>
      (await getFamilies()).family(fid);

  Future<FamilyPerson> getPerson(String fid, String pid) async {
    final family = await getFamily(fid);
    return FamilyPerson(family: family, person: family.person(pid));
  }
}

class Repository2 {
  Repository2._(this.userName);
  final String userName;

  static Future<Repository2> get(String userName) async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));
    return Repository2._(userName);
  }

  static final rnd = Random();

  Future<List<Family>> getFamilies() async {
    // simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate error
    // if (rnd.nextBool()) throw Exception('error fetching families');

    // return data "fetched over the network"
    return Families.data;
  }

  Future<Family> getFamily(String fid) async =>
      (await getFamilies()).family(fid);

  Future<FamilyPerson> getPerson(String fid, String pid) async {
    final family = await getFamily(fid);
    return FamilyPerson(family: family, person: family.person(pid));
  }
}

abstract class StateStream<T> {
  StateStream();

  StateStream.seeded(T value) : state = value {
    _controller.add(value);
  }

  final StreamController<T> _controller = StreamController<T>();
  late T state;

  Stream<T> get stream => _controller.stream;

  void emit(T state) {
    this.state = state;
    _controller.add(state);
  }

  void dispose() {
    _controller.close();
  }
}

class LoggedInState extends StateStream<bool> {
  LoggedInState();

  // ignore: avoid_positional_boolean_parameters
  LoggedInState.seeded(bool value) : super.seeded(value);
}

void main() => runApp(App());

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  static const title = 'GoRouter Example: Nested Navigation';

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        routeInformationProvider: _router.routeInformationProvider,
        title: title,
      );

  late final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        redirect: (_) => '/family/${Families.data[0].id}',
      ),
      GoRoute(
        path: '/family/:fid',
        builder: (context, state) => FamilyTabsScreen(
          key: state.pageKey,
          selectedFamily: Families.family(state.params['fid']!),
        ),
        routes: [
          GoRoute(
            path: 'person/:pid',
            builder: (context, state) {
              final family = Families.family(state.params['fid']!);
              final person = family.person(state.params['pid']!);

              return PersonScreen(family: family, person: person);
            },
          ),
        ],
      ),
    ],

    // show the current router location as the user navigates page to page; note
    // that this is not required for nested navigation but it is useful to show
    // the location as it changes
    navigatorBuilder: (context, state, child) => Material(
      child: Column(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(state.location),
          ),
        ],
      ),
    ),
  );
}

class FamilyTabsScreen extends StatefulWidget {
  FamilyTabsScreen({required Family selectedFamily, Key? key})
      : index = Families.data.indexWhere((f) => f.id == selectedFamily.id),
        super(key: key) {
    assert(index != -1);
  }

  final int index;

  @override
  _FamilyTabsScreenState createState() => _FamilyTabsScreenState();
}

class _FamilyTabsScreenState extends State<FamilyTabsScreen>
    with TickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: Families.data.length,
      vsync: this,
      initialIndex: widget.index,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FamilyTabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.index = widget.index;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(App.title),
          bottom: TabBar(
            controller: _controller,
            tabs: [for (final f in Families.data) Tab(text: f.name)],
            onTap: (index) => _tap(context, index),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [for (final f in Families.data) FamilyView(family: f)],
        ),
      );

  void _tap(BuildContext context, int index) =>
      context.go('/family/${Families.data[index].id}');
}

class FamilyView extends StatefulWidget {
  const FamilyView({required this.family, Key? key}) : super(key: key);
  final Family family;

  @override
  State<FamilyView> createState() => _FamilyViewState();
}

/// Use the [AutomaticKeepAliveClientMixin] to keep the state, like scroll
/// position and text fields when switching tabs, as well as when popping back
/// from sub screens. To use the mixin override [wantKeepAlive] and call
/// `super.build(context)` in build.
///
/// In this example if you make a web build and make the browser window so low
/// that you have to scroll to see the last person on each family tab, you will
/// see that state is kept when you switch tabs and when you open a person
/// screen and pop back to the family.
class _FamilyViewState extends State<FamilyView>
    with AutomaticKeepAliveClientMixin {
  // Override `wantKeepAlive` when using `AutomaticKeepAliveClientMixin`.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Call `super.build` when using `AutomaticKeepAliveClientMixin`.
    super.build(context);
    return ListView(
      children: [
        for (final p in widget.family.people)
          ListTile(
            title: Text(p.name),
            onTap: () =>
                context.go('/family/${widget.family.id}/person/${p.id}'),
          ),
      ],
    );
  }
}

class PersonScreen extends StatelessWidget {
  const PersonScreen({required this.family, required this.person, Key? key})
      : super(key: key);

  final Family family;
  final Person person;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(person.name)),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await showDialog(
              context: context,
              useSafeArea: true,
              builder: (context) => const AlertDialog(
                title: Text("Test dialog"),
              ),
            );
          },
          child: const Icon(Icons.dialer_sip),
        ),
        body: Text('${person.name} ${family.name} is ${person.age} years old'),
      );
}
