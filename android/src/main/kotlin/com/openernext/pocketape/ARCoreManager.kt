package com.openernext.pocketape

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
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
                arSceneView?.arFrame?.let { frame -> sendMeasure(frame) }
            }
            updateListener?.let { scene.addOnUpdateListener(it) }
        }
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
                Log.e("pocketape", "Camera permission is required for AR functionality.")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    public fun stopSession() {
        Log.d("MyTag", "Stop")
        session?.pause()
        arSceneView?.pause()
        arSceneView?.scene?.let { scene ->
            updateListener?.let { scene.removeOnUpdateListener(it) }
        }
        arSceneView?.destroy()
        session?.close()
        session = null
    }

    private fun sendMeasure(frame: Frame) {
        var x = frame.camera.displayOrientedPose.translation
        Log.d("MyTag", "${x[0]} ${x[1]} ${x[2]}")
        plugin.sendEventToFlutter(x)
    }
}

