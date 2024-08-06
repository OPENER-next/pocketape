package com.example.pocketape

import android.content.Context
import android.content.pm.PackageManager
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.google.ar.core.*
import com.google.ar.core.exceptions.*
import com.google.ar.sceneform.ArSceneView

class ARCoreManager(private val context: Context,  private val plugin: PocketapePlugin) {
    private var session: Session? = null
    private lateinit var arSceneView: ArSceneView
    private var currentPosition: FloatArray? = null

    init {
        if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED) {
            initializeARSession()
            initializeARSceneView()
        }
        else {
            Toast.makeText(context, "Camera permission is required for AR functionality.", Toast.LENGTH_LONG).show()
        }
    }

    private fun initializeARSession() {
        try {
            session = Session(context)
            val config = Config(session).apply {
                updateMode =  Config.UpdateMode.LATEST_CAMERA_IMAGE
                depthMode = Config.DepthMode.AUTOMATIC
            }
            session?.configure(config)
        } catch (e: UnavailableArcoreNotInstalledException) {
            e.printStackTrace()
        } catch (e: UnavailableApkTooOldException) {
            e.printStackTrace()
        } catch (e: UnavailableSdkTooOldException) {
            e.printStackTrace()
        } catch (e: UnavailableDeviceNotCompatibleException) {
            e.printStackTrace()
        }
    }

    private fun initializeARSceneView() {
        arSceneView = ArSceneView(context)
        arSceneView.setupSession(session)
        arSceneView.scene.addOnUpdateListener {
            arSceneView.arFrame?.let { handleFrameUpdate(it) }
        }
    }

    private fun handleFrameUpdate(frame: Frame) {
        val camera = frame.camera
        val pose = camera.displayOrientedPose
        currentPosition = pose.translation
        sendMeasure()
    }

    fun startSession() {
        try {
            session?.resume()
            arSceneView.resume()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun stopSession() {
        session?.pause()
        arSceneView.pause()
    }

    private fun sendMeasure() {
        val vectorArray: FloatArray = currentPosition ?: floatArrayOf(0f, 0f, 0f)
        plugin.sendEventToFlutter(vectorArray)
    }
}

