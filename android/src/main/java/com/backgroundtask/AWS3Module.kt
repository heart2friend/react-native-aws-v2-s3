package com.awss3

import android.os.Handler
import android.os.Looper

import androidx.lifecycle.Observer
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Data
import androidx.work.Constraints
import androidx.work.NetworkType
import androidx.work.ExistingWorkPolicy

import com.facebook.react.bridge.*

import java.util.List;
import java.util.UUID;

class AWS3Module(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "AWS3Module"
    }

    @ReactMethod
    fun uploadFileToS3(workId : String, filePath : String,bucketName: String, region: String, accessKey: String, secreteKey: String,s3Key: String, promise: Promise) {

        val inputData = Data.Builder()
            .putString("workId", workId)
            .putString("filePath", filePath)
            .putString("bucketName", bucketName)
            .putString("region", region)
            .putString("accessKey", accessKey)
            .putString("secreteKey", secreteKey)
            .putString("s3Key", s3Key)

            .build()

        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)  // Requires active internet connection
            //.setRequiresBatteryNotLow(true)                // Battery level must not be low
            .build()

        val workRequest = OneTimeWorkRequestBuilder<S3Worker>()
        .setInputData(inputData)
        .setConstraints(constraints)
        .build()
        
        val workManager = WorkManager.getInstance(reactApplicationContext)

        workManager.enqueueUniqueWork(workId, ExistingWorkPolicy.KEEP, workRequest)
 
        //Observe the work's result
        Handler(Looper.getMainLooper()).post {workManager.getWorkInfoByIdLiveData(workRequest.id).observeForever(object : Observer<androidx.work.WorkInfo> {
            override fun onChanged(workInfo: androidx.work.WorkInfo?) {
                if (workInfo != null && workInfo.state.isFinished) {
                    // Remove the observer to avoid memory leaks
                    workManager.getWorkInfoByIdLiveData(workRequest.id).removeObserver(this)

                    if (workInfo.state == androidx.work.WorkInfo.State.SUCCEEDED) {
                        // Get the output data                        
                        val status = workInfo.outputData.getString("status")
                        val workId = workInfo.outputData.getString("workId")

                        // Return output to React Native
                        val result = Arguments.createMap().apply {
                            putString("status",status)
                            putString("workId", workId)
                        }

                        promise.resolve(result);
                    
                    } else {                        
                        promise.reject("ERROR", "Work failed or was cancelled")
                    }
                }
            }
        })
    }
    }

    @ReactMethod
    fun getWorkStatus(workId: String, promise: Promise) {
        try {
            // Fetch the WorkInfo list for the given unique work ID
            val workInfos = WorkManager.getInstance(reactApplicationContext)
                .getWorkInfosForUniqueWork(workId)
                .get() // This blocks until the result is available (use with care in production)

            if (workInfos.isEmpty()) {
                promise.reject("NO_WORK_FOUND", "No work found for the provided ID.")
                return
            }

            // Get the state of the first WorkInfo
            val state = workInfos[0].state
            
            promise.resolve(state.toString()) // Return the state as a string (e.g., "ENQUEUED", "RUNNING", "SUCCEEDED")

        } catch (e: Exception) {
            promise.reject("ERROR", e.message)
        }
    }

    @ReactMethod
    fun cancelUniqueWork(workId: String, promise: Promise) {
        try {
            WorkManager.getInstance(reactApplicationContext)
                .cancelUniqueWork(workId)

            promise.resolve("Work with name $workId cancelled successfully.")

        } catch (e: Exception) {
            promise.reject("ERROR", "Failed to cancel work: ${e.message}")
        }
    }
}
