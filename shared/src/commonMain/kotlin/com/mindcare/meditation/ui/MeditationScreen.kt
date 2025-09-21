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
import com.mindcare.meditation.MeditationViewModel
import com.mindcare.meditation.components.CategoryChip
import com.mindcare.meditation.components.MeditationPlayerDialog
import com.mindcare.meditation.components.MeditationSessionCard
import com.mindcare.meditation.model.MeditationCategory

@Composable
fun MeditationScreen(
    viewModel: MeditationViewModel,
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
        // Resto del código igual que en la versión Android...
    }
} 