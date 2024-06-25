part of 'home_page.dart';

class HomePageDesktop extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HomePageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 360,
        height: double.infinity,
        color: Colors.white,
        child: const ProfileContent(),
      ),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _SessionListBar(scaffoldKey: scaffoldKey),
              const Divider(),
              const Expanded(
                child: SessionListView(),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: BlocBuilder<SessionCubit, SessionState>(
            buildWhen: (c, p) => c.currentSession != p.currentSession,
            builder: (context, state) {
              final session =
                  SessionCubit.of(context).getSession(state.currentSession);
              if (session == null) {
                return const SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: WindowBarActions(),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text("Select a session to start chat !")
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SessionPage(session: session);
            },
          ),
        )
      ],
    );
  }
}
