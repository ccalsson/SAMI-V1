@Singleton
class AudioManager @Inject constructor(
    private val context: Context
) {
    private var mediaPlayer: MediaPlayer? = null
    private var progressCallback: ((Float) -> Unit)? = null
    private var progressUpdateJob: Job? = null

    fun prepare(audioUrl: String) {
        mediaPlayer?.release()
        mediaPlayer = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .build()
            )
            setDataSource(audioUrl)
            prepareAsync()
        }
    }

    fun start() {
        mediaPlayer?.start()
        startProgressUpdates()
    }

    fun pause() {
        mediaPlayer?.pause()
        stopProgressUpdates()
    }

    fun resume() {
        mediaPlayer?.start()
        startProgressUpdates()
    }

    fun stop() {
        mediaPlayer?.stop()
        stopProgressUpdates()
    }

    fun release() {
        mediaPlayer?.release()
        mediaPlayer = null
        stopProgressUpdates()
    }

    fun setOnProgressListener(callback: (Float) -> Unit) {
        progressCallback = callback
    }

    private fun startProgressUpdates() {
        progressUpdateJob = CoroutineScope(Dispatchers.Main).launch {
            while (isActive) {
                mediaPlayer?.let { player ->
                    val progress = player.currentPosition.toFloat() / player.duration
                    progressCallback?.invoke(progress)
                }
                delay(1000)
            }
        }
    }

    private fun stopProgressUpdates() {
        progressUpdateJob?.cancel()
        progressUpdateJob = null
    }
} 