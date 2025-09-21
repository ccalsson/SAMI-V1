@Singleton
class MeditationRepository @Inject constructor(
    private val meditationDao: MeditationDao,
    private val apiService: ApiService,
    private val sessionManager: SessionManager,
    private val audioManager: AudioManager,
    private val dispatchers: CoroutineDispatchers
) {
    private val _currentAudioProgress = MutableStateFlow<Float>(0f)
    val currentAudioProgress = _currentAudioProgress.asStateFlow()

    fun getAllSessions(): Flow<List<MeditationSession>> = flow {
        try {
            // Primero emitimos datos locales
            emitAll(meditationDao.getAllSessions().map { entities ->
                entities.map { it.toDomain() }
            })

            // Luego intentamos actualizar desde la red
            val remoteSessions = apiService.getMeditationSessions()
            meditationDao.insertSessions(remoteSessions.map { it.toEntity() })
        } catch (e: Exception) {
            // Si falla la red, seguimos usando datos locales
            Timber.e(e, "Error fetching meditation sessions")
        }
    }.flowOn(dispatchers.io)

    suspend fun startSession(sessionId: String) {
        withContext(dispatchers.io) {
            val session = meditationDao.getSessionById(sessionId) ?: return@withContext
            val userId = sessionManager.getCurrentUserId()

            try {
                audioManager.prepare(session.audioUrl)
                audioManager.setOnProgressListener { progress ->
                    _currentAudioProgress.value = progress
                }
                audioManager.start()

                // Registrar inicio de sesión
                val progress = MeditationProgressEntity(
                    sessionId = sessionId,
                    completedTime = 0,
                    totalTime = session.duration * 60, // convertir a segundos
                    lastPlayedPosition = 0,
                    userId = userId
                )
                meditationDao.insertProgress(progress)

                // Registrar analíticas
                analyticsManager.logEvent(
                    AnalyticsEvent.MeditationStarted(
                        sessionId = sessionId,
                        category = session.category
                    )
                )
            } catch (e: Exception) {
                Timber.e(e, "Error starting meditation session")
                throw e
            }
        }
    }

    suspend fun saveProgress(progress: MeditationProgress) {
        withContext(dispatchers.io) {
            val userId = sessionManager.getCurrentUserId()
            meditationDao.insertProgress(
                progress.toEntity(userId)
            )
        }
    }

    fun getSessionProgress(sessionId: String): Flow<MeditationProgress?> {
        val userId = sessionManager.getCurrentUserId()
        return meditationDao.getProgress(sessionId, userId)
            .map { it?.toDomain() }
    }

    suspend fun pauseSession() {
        audioManager.pause()
    }

    suspend fun resumeSession() {
        audioManager.resume()
    }

    fun getSessionsByCategory(category: MeditationCategory): Flow<List<MeditationSession>> {
        return meditationDao.getSessionsByCategory(category.name)
            .map { entities -> entities.map { it.toDomain() } }
    }

    private fun MeditationEntity.toDomain(): MeditationSession {
        return MeditationSession(
            id = id,
            title = title,
            description = description,
            duration = duration,
            category = MeditationCategory.valueOf(category),
            audioUrl = audioUrl,
            imageUrl = imageUrl,
            isPremium = isPremium
        )
    }

    private fun MeditationProgressEntity.toDomain(): MeditationProgress {
        return MeditationProgress(
            sessionId = sessionId,
            completedTime = completedTime,
            totalTime = totalTime,
            lastPlayedPosition = lastPlayedPosition
        )
    }
} 