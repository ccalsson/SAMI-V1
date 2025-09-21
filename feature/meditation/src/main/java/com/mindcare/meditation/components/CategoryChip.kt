package com.mindcare.meditation.components

import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.mindcare.meditation.model.MeditationCategory

@Composable
fun CategoryChip(
    category: MeditationCategory?,
    isSelected: Boolean,
    onClick: (() -> Unit)?
) {
    val text = when (category) {
        MeditationCategory.SLEEP -> "Sueño"
        MeditationCategory.FOCUS -> "Concentración"
        MeditationCategory.ANXIETY -> "Ansiedad"
        MeditationCategory.STRESS -> "Estrés"
        MeditationCategory.MINDFULNESS -> "Mindfulness"
        MeditationCategory.BEGINNER -> "Principiantes"
        null -> "Todos"
    }
    
    Surface(
        onClick = { onClick?.invoke() },
        enabled = onClick != null,
        color = if (isSelected) 
            MaterialTheme.colorScheme.primary 
        else 
            MaterialTheme.colorScheme.surfaceVariant,
        contentColor = if (isSelected) 
            MaterialTheme.colorScheme.onPrimary 
        else 
            MaterialTheme.colorScheme.onSurfaceVariant,
        shape = RoundedCornerShape(16.dp)
    ) {
        Text(
            text = text,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
            style = MaterialTheme.typography.labelMedium
        )
    }
} 