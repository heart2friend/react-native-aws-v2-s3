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
import java.io.File

class AWS3Module(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "AWS3Module"
    }

    @ReactMethod
    fun uploadFileToS3(workId : String, filePath : String,bucketName: String, region: String, accessKey: String, secreteKey: String,s3Key: String, promise: Promise) {
    
        try
        {
            val inputData = Data.Builder()
                .putString("workId", workId)
                .putString("filePath", filePath)
                .putString("bucketName", bucketName)
                .putString("region", region)
                .putString("accessKey", accessKey)
                .putString("secreteKey", secreteKey)
                .putString("s3Key", s3Key)
                .build()

            val file = File(filePath)

            if (!file.exists()) {
                     // Return output to React Native
                val userInfo = Arguments.createMap().apply {
                    putString("workId", workId)
                    putString("status", "Failed")                           
                }

                promise.reject("1000", "File not found.", userInfo)    
            }
           
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

                        // Get the output data        
                        val status = workInfo.outputData.getString("status")
                        val workId = workInfo.outputData.getString("workId")

                        // Return output to React Native
                        val userInfo = Arguments.createMap().apply {
                            putString("workId", workId)
                            putString("status", status)                           
                        }

                        if (workInfo.state == androidx.work.WorkInfo.State.SUCCEEDED) {
                            promise.resolve(userInfo);                    
                        } else {  
                            // Define the error message and details
                            val errorMessage = "Upload work failed or was cancelled"               
                            // Reject the promise with an error code, message, and details
                            promise.reject("1001", errorMessage, Exception(errorMessage), userInfo)
                        }
                    }
                }
            })}
        } catch (e: Exception) {
            
            val userInfo = Arguments.createMap().apply {
                putString("workId", workId)
                putString("status", "Failed") 
                putString("error", e.message)                        
            }

            promise.reject("2001", "Error occurred in uploading work.", userInfo)
        }       
    }

    @ReactMethod
    fun getUploadStatus(workId: String, promise: Promise) {
        try {
            // Fetch the WorkInfo list for the given unique work ID
            val workInfos = WorkManager.getInstance(reactApplicationContext)
                .getWorkInfosForUniqueWork(workId)
                .get() // This blocks until the result is available (use with care in production)

            if (workInfos.isEmpty()) {

                // Return output to React Native
                val userInfo = Arguments.createMap().apply {
                    putString("workId", workId)
                    putString("status", "NotFound")                           
                }

                promise.reject("1002", "No upload work found for the provided workId", userInfo)
                
            }
            else
            {              
                // Return output to React Native
                val userInfo = Arguments.createMap().apply {
                    putString("workId", workId)
                    putString("status", workInfos[0].state.toString()) // Return the state as a string (e.g., "ENQUEUED", "RUNNING", "SUCCEEDED")                          
                }

                promise.resolve(userInfo) 
            }

        } catch (e: Exception) {
            
            val userInfo = Arguments.createMap().apply {
                putString("workId", workId)
                putString("status", "Failed")     
                putString("error", e.message)                          
            }

            promise.reject("2002", "Error occurred while getting work status.", userInfo)
        }
    }

    @ReactMethod
    fun cancelUpload(workId: String, promise: Promise) {
        try {

               // Fetch the WorkInfo list for the given unique work ID
               val workInfos = WorkManager.getInstance(reactApplicationContext)
               .getWorkInfosForUniqueWork(workId)
               .get() // This blocks until the result is available (use with care in production)

           if (workInfos.isEmpty()) 
            {
                // Return output to React Native
                val userInfo = Arguments.createMap().apply {
                    putString("workId", workId)
                    putString("status", "NotFound")                           
                }

                promise.reject("1002", "No upload work found for the provided workId", userInfo)

            }
            else
            {
                WorkManager.getInstance(reactApplicationContext)
                    .cancelUniqueWork(workId)

                // Return output to React Native
                val userInfo = Arguments.createMap().apply {
                    putString("workId", workId)
                    putString("status", "Cancelled")                           
                }

                promise.resolve(userInfo)
            }

        } catch (e: Exception) {

            val userInfo = Arguments.createMap().apply {
                putString("workId", workId)
                putString("status", "Failed")  
                putString("error", e.message)                             
            }

            promise.reject("2003", "Error occurred while cancelling upload work.", userInfo)
        }
    }
}
