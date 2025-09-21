@Composable
fun BreathingExercisePlayer(
    exercise: BreathingExercise,
    progress: BreathingProgress?,
    isActive: Boolean,
    onPause: () -> Unit,
    onResume: () -> Unit,
    onClose: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        IconButton(
            onClick = onClose,
            modifier = Modifier.align(Alignment.Start)
        ) {
            Icon(Icons.Default.Close, "Cerrar")
        }

        Spacer(modifier = Modifier.height(32.dp))

        BreathingAnimation(
            phase = progress?.currentPhase,
            remainingSeconds = progress?.remainingSeconds ?: 0,
            modifier = Modifier.size(200.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = when (progress?.currentPhase) {
                BreathingPhase.INHALE -> "Inhala"
                BreathingPhase.HOLD_INHALE -> "Mantén"
                BreathingPhase.EXHALE -> "Exhala"
                BreathingPhase.HOLD_EXHALE -> "Mantén"
                null -> "Prepárate..."
            },
            style = MaterialTheme.typography.headlineMedium
        )

        Text(
            text = "${progress?.remainingSeconds ?: 0}",
            style = MaterialTheme.typography.displayLarge
        )

        Spacer(modifier = Modifier.height(16.dp))

        LinearProgressIndicator(
            progress = progress?.let { 
                it.completedCycles.toFloat() / it.totalCycles 
            } ?: 0f,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 32.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = if (isActive) onPause else onResume,
                modifier = Modifier.size(64.dp)
            ) {
                Icon(
                    imageVector = if (isActive) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = if (isActive) "Pausar" else "Continuar",
                    modifier = Modifier.size(32.dp)
                )
            }
        }
    }
}

@Composable
private fun BreathingAnimation(
    phase: BreathingPhase?,
    remainingSeconds: Int,
    modifier: Modifier = Modifier
) {
    val transition = updateTransition(
        targetState = phase to remainingSeconds,
        label = "breathing"
    )

    val scale by transition.animateFloat(
        label = "scale",
        transitionSpec = {
            when (targetState.first) {
                BreathingPhase.INHALE -> tween(
                    durationMillis = targetState.second * 1000,
                    easing = FastOutSlowInEasing
                )
                BreathingPhase.EXHALE -> tween(
                    durationMillis = targetState.second * 1000,
                    easing = SlowOutFastInEasing
                )
                else -> snap()
            }
        }
    ) { (phase, _) ->
        when (phase) {
            BreathingPhase.INHALE -> 1.5f
            BreathingPhase.EXHALE -> 1f
            else -> 1.25f
        }
    }

    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .scale(scale)
        ) {
            drawCircle(
                color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f),
                radius = size.minDimension / 2
            )
            drawCircle(
                color = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                radius = size.minDimension / 2.5f
            )
        }
    }
} 