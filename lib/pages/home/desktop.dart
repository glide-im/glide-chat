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
              WithMacOsBarPadding(
                child: _SessionListBar(scaffoldKey: scaffoldKey),
              ),
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
              final session = SessionCubit.of(context).getSession(state.currentSession);
              if (session == null) {
                return _NoSession();
              }
              return SessionPage(key: ValueKey(session), session: session);
            },
          ),
        )
      ],
    );
  }
}

class _NoSession extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: ColoredBox(
        color: context.theme.colorScheme.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: WindowBarActions(),
            ),
            Center(
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 120,
                height: 120,
                color: context.theme.iconTheme.color?.withAlpha(128),
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
