package com.awss3

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.Data

import com.amazonaws.auth.BasicAWSCredentials
import com.amazonaws.services.s3.model.PutObjectRequest
import com.amazonaws.services.s3.AmazonS3
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.regions.Region
import java.io.File

class S3Worker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    companion object {
        private const val TAG = "S3Worker"
    }

    override fun doWork(): Result {
        return try {

        val workId = inputData.getString("workId") ?: return Result.failure()
        val filePath = inputData.getString("filePath") ?: return Result.failure()
        val bucketName = inputData.getString("bucketName") ?: return Result.failure()
        val accessKey = inputData.getString("accessKey") ?: return Result.failure()
        val secreteKey = inputData.getString("secreteKey") ?: return Result.failure()
        val region = inputData.getString("region") ?: return Result.failure()
        val s3Key = inputData.getString("s3Key") ?: return Result.failure()
        
        val awsCredentials = BasicAWSCredentials(accessKey, secreteKey)

        val s3Client: AmazonS3 = AmazonS3Client(awsCredentials).apply {
            setRegion(Region.getRegion(region))
        }

        val file = File(filePath)

        try {
            // Create a PutObjectRequest
            val request = PutObjectRequest(bucketName, s3Key, file)

            // Upload the file to S3
            s3Client.putObject(request)

            // Log a message if the upload is successful
             Log.d(TAG,"Upload Successful: $s3Key")

        } catch (e: Exception) {
            Log.d(TAG,"Error uploading file: ${e.message}")
        }

            Log.d(TAG, "Work Id: $workId")

            // Prepare output data
            val outputData = Data.Builder()
                .putString("status","success")
                .putString("workId", workId)
                .build()

            // Return success with output data
            Result.success(outputData);

        } catch (e: Exception) {
            Log.e(TAG, "Error uploading file", e)
            Result.failure()
        }
    }
}
