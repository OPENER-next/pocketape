package com.example.pocketape

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.google.ar.core.*
import com.google.ar.core.exceptions.*
import com.google.ar.sceneform.ArSceneView
import com.google.ar.sceneform.Scene

class ARCoreManager(private val context: Context,  private val plugin: PocketapePlugin) {
    private var session: Session? = null
    private var arSceneView: ArSceneView? = null
    private var updateListener: Scene.OnUpdateListener? = null

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
        arSceneView?.setupSession(session)
        arSceneView?.scene?.let { scene ->
            updateListener = Scene.OnUpdateListener {
                arSceneView?.arFrame?.let { frame -> handleFrameUpdate(frame) }
            }
            updateListener?.let { scene.addOnUpdateListener(it) }
        }
    }

    private fun handleFrameUpdate(frame: Frame) {
        sendMeasure(frame)
    }

    fun startSession() {
        Log.d("MyTag", "Start")
        try {
            if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED) {
                initializeARSession()
                initializeARSceneView()
                session?.resume()
                arSceneView?.resume()
            }
            else {
                Toast.makeText(context, "Camera permission is required for AR functionality.", Toast.LENGTH_LONG).show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun stopSession() {
        Log.d("MyTag", "Stop")
        session?.pause()
        arSceneView?.pause()
        onDestroy()
    }

    private fun sendMeasure(frame: Frame) {
        var x = frame.camera.displayOrientedPose.translation
        Log.d("MyTag", "${x[0]} ${x[1]} ${x[2]}")
        plugin.sendEventToFlutter(x)
    }

    public fun onDestroy() {
        arSceneView?.scene?.let { scene ->
            updateListener?.let { scene.removeOnUpdateListener(it) }
        }
        arSceneView?.destroy()
        session?.close()
        session = null
    }
}

