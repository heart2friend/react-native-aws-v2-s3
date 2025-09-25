package com.awss3

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.Data
import com.amazonaws.auth.BasicAWSCredentials
import com.amazonaws.services.s3.model.PutObjectRequest
import com.amazonaws.services.s3.AmazonS3
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.regions.Region
import com.amazonaws.regions.Regions
import java.io.File

class S3Worker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    companion object {
        private const val TAG = "S3Worker"
    }

    override fun doWork(): Result {
        val workId = inputData.getString("workId") ?: return Result.failure()
        val filePath = inputData.getString("filePath") ?: return Result.failure()
        val bucketName = inputData.getString("bucketName") ?: return Result.failure()
        val accessKey = inputData.getString("accessKey") ?: return Result.failure()
        val secretKey = inputData.getString("secreteKey") ?: return Result.failure()
        val region = inputData.getString("region") ?: return Result.failure()
        val s3Key = inputData.getString("s3Key") ?: return Result.failure()

        return try {
            val awsCredentials = BasicAWSCredentials(accessKey, secretKey)
            val s3Client: AmazonS3 = AmazonS3Client(awsCredentials).apply {
                setRegion(Region.getRegion(Regions.fromName(region)))
            }

            val file = File(filePath)
            if (!file.exists()) {
                Log.e(TAG, "File not found: $filePath")
                return Result.failure(
                    Data.Builder().putString("error", "File not found").build()
                )
            }

            return try {
                val request = PutObjectRequest(bucketName, s3Key, file)
                s3Client.putObject(request)

                Log.d(TAG, "Upload Successful: $s3Key")

                Result.success(
                    Data.Builder()
                        .putString("status", "Success")
                        .putString("workId", workId)
                        .putString("s3Key", s3Key)
                        .build()
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error uploading file: ${e.message}", e)
                Result.failure(
                    Data.Builder()
                        .putString("status", "Failed")
                        .putString("workId", workId)
                        .putString("error", e.message)
                        .build()
                )
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error initializing S3 client", e)
            Result.failure(
                Data.Builder()
                    .putString("status", "Failed")
                    .putString("error", e.message)
                    .build()
            )
        }
    }
}
