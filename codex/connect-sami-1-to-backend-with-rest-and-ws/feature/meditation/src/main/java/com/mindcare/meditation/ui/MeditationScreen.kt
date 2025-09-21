package com.mindcare.meditation.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.mindcare.meditation.MeditationViewModel
import com.mindcare.meditation.components.CategoryChip
import com.mindcare.meditation.components.MeditationPlayerDialog
import com.mindcare.meditation.components.MeditationSessionCard
import com.mindcare.meditation.model.MeditationCategory

@Composable
fun MeditationScreen(
    viewModel: MeditationViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit
) {
    val sessions by viewModel.sessions.collectAsState()
    val currentSession by viewModel.currentSession.collectAsState()
    val selectedCategory by viewModel.selectedCategory.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        TopAppBar(
            title = { Text("Meditación") },
            navigationIcon = {
                IconButton(onClick = onNavigateBack) {
                    Icon(Icons.Default.ArrowBack, "Volver")
                }
            }
        )

        // Categorías
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            contentPadding = PaddingValues(vertical = 16.dp)
        ) {
            item {
                CategoryChip(
                    category = null,
                    isSelected = selectedCategory == null,
                    onClick = { viewModel.selectCategory(null) }
                )
            }
            items(MeditationCategory.values()) { category ->
                CategoryChip(
                    category = category,
                    isSelected = selectedCategory == category,
                    onClick = { viewModel.selectCategory(category) }
                )
            }
        }

        // Lista de sesiones
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp),
            contentPadding = PaddingValues(vertical = 8.dp)
        ) {
            items(sessions) { session ->
                MeditationSessionCard(
                    session = session,
                    onClick = { viewModel.playSession(session.id) }
                )
            }
        }
    }

    // Reproductor de meditación
    if (currentSession != null) {
        MeditationPlayerDialog(
            session = currentSession!!,
            onDismiss = { viewModel.stopSession() }
        )
    }
} 