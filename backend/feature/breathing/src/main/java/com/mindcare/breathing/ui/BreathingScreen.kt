@Composable
fun BreathingScreen(
    viewModel: BreathingViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit
) {
    val exercises by viewModel.exercises.collectAsState()
    val currentExercise by viewModel.currentExercise.collectAsState()
    val progress by viewModel.progress.collectAsState()
    val isActive by viewModel.isActive.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        TopAppBar(
            title = { Text("Ejercicios de Respiración") },
            navigationIcon = {
                IconButton(onClick = onNavigateBack) {
                    Icon(Icons.Default.ArrowBack, "Volver")
                }
            }
        )

        if (currentExercise == null) {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp),
                contentPadding = PaddingValues(vertical = 16.dp)
            ) {
                items(exercises) { exercise ->
                    BreathingExerciseCard(
                        exercise = exercise,
                        onClick = { viewModel.startExercise(exercise.id) }
                    )
                }
            }
        } else {
            BreathingExercisePlayer(
                exercise = currentExercise!!,
                progress = progress,
                isActive = isActive,
                onPause = { viewModel.pauseExercise() },
                onResume = { viewModel.resumeExercise() },
                onClose = {
                    viewModel.pauseExercise()
                    currentExercise = null
                }
            )
        }
    }
} 