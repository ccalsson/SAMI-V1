@Entity(tableName = "meditation_sessions")
data class MeditationEntity(
    @PrimaryKey
    val id: String,
    val title: String,
    val description: String,
    val duration: Int,
    val category: String,
    val audioUrl: String,
    val imageUrl: String,
    val isPremium: Boolean,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "meditation_progress")
data class MeditationProgressEntity(
    @PrimaryKey
    val sessionId: String,
    val completedTime: Int,
    val totalTime: Int,
    val lastPlayedPosition: Long,
    val lastUpdated: Long = System.currentTimeMillis(),
    val userId: String
) 