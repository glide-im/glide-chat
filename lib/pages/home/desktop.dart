part of 'home_page.dart';

class HomePageDesktop extends StatelessWidget {
  const HomePageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _SessionListBar(),
              const Divider(),
              Expanded(
                child: BlocBuilder<GlobalCubit, GlobalState>(
                  buildWhen: (c, p) => c.initialized != p.initialized,
                  builder: (context, state) {
                    if (!state.initialized) {
                      return Center(
                        child: IconButton(
                          onPressed: () async {
                            await context.read<GlobalCubit>().login();
                          },
                          icon: const Icon(Icons.replay_circle_filled_rounded),
                        ),
                      );
                    }
                    return const SessionListView();
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 2,
          child: BlocBuilder<GlobalCubit, GlobalState>(
            buildWhen: (c, p) => c.currentSession != p.currentSession,
            builder: (context, state) {
              final session =
                  GlobalCubit.of(context).getSession(state.currentSession);
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
