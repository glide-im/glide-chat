part of 'home_page.dart';

class HomePageMobile extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 260,
        height: double.infinity,
        color: Colors.white,
        child: const ProfileContent(),
      ),
      appBar: barMobile(),
      floatingActionButton: Adaptive(
        L: (c) => null,
        builder: (c) {
          return BlocBuilder<GlobalCubit, GlobalState>(
            buildWhen: (previous, current) => previous.state != current.state,
            builder: (context, state) {
              if (state.state == GlideState.init) {
                return const SizedBox();
              }
              return FloatingActionButton(
                onPressed: () async {
                  //
                },
                child: const Icon(Icons.add_rounded),
              );
            },
          );
        },
      ),
      body: const SessionListView(),
    );
  }

  AppBar barMobile() {
    return AppBar(
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      title: const WithGlideStateText(title: Text("Glide")),
    );
  }
}
