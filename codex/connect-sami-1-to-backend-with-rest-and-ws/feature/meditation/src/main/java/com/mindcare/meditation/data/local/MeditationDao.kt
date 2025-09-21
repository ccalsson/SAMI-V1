@Dao
interface MeditationDao {
    @Query("SELECT * FROM meditation_sessions ORDER BY createdAt DESC")
    fun getAllSessions(): Flow<List<MeditationEntity>>

    @Query("SELECT * FROM meditation_sessions WHERE id = :sessionId")
    suspend fun getSessionById(sessionId: String): MeditationEntity?

    @Query("SELECT * FROM meditation_progress WHERE sessionId = :sessionId AND userId = :userId")
    fun getProgress(sessionId: String, userId: String): Flow<MeditationProgressEntity?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSession(session: MeditationEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProgress(progress: MeditationProgressEntity)

    @Query("SELECT * FROM meditation_sessions WHERE category = :category")
    fun getSessionsByCategory(category: String): Flow<List<MeditationEntity>>

    @Transaction
    @Query("SELECT * FROM meditation_progress WHERE userId = :userId ORDER BY lastUpdated DESC")
    fun getUserProgress(userId: String): Flow<List<MeditationProgressEntity>>
} 