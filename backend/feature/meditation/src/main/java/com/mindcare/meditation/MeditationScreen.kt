@Composable
fun MeditationScreen(
    viewModel: MeditationViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit
) {
    var selectedSession by remember { mutableStateOf<MeditationSession?>(null) }

    Column(modifier = Modifier.fillMaxSize()) {
        TopAppBar(
            title = { Text("Meditación") },
            navigationIcon = {
                IconButton(onClick = onNavigateBack) {
                    Icon(Icons.Default.ArrowBack, "Volver")
                }
            }
        )

        LazyColumn {
            items(viewModel.sessions) { session ->
                MeditationSessionCard(
                    session = session,
                    onClick = { selectedSession = session }
                )
            }
        }
    }

    selectedSession?.let { session ->
        MeditationPlayerDialog(
            session = session,
            onDismiss = { selectedSession = null }
        )
    }
} 