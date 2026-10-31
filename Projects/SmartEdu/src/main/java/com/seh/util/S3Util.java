package com.seh.util;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.HttpMethod;

import jakarta.servlet.ServletContext;

import java.io.InputStream;
import java.net.URL;
import java.util.Date;

/**
 * Utility class for AWS S3 operations used by the admin document flow.
 *
 * Credentials are sourced automatically from the EC2 instance role
 * (SmartEduS3Role) via the AWS Default Credential Provider Chain.
 * No access keys are needed in code or config.
 */
public class S3Util {

    private static AmazonS3 buildClient(ServletContext ctx) {
        String region = ctx.getInitParameter("AWS_S3_REGION");

        // DefaultAWSCredentialsProviderChain is used automatically —
        // on EC2 it picks up credentials from the attached IAM role.
        return AmazonS3ClientBuilder.standard()
                .withRegion(region)
                .build();
    }

    /**
     * Upload a file to S3.
     *
     * @param ctx         ServletContext (to read config)
     * @param inputStream File bytes
     * @param s3Key       Object key e.g. "timetables/1740000000_file.pdf"
     * @param contentType MIME type e.g. "application/pdf"
     * @param fileSize    File size in bytes
     */
    public static void uploadFile(ServletContext ctx,
                                  InputStream inputStream,
                                  String s3Key,
                                  String contentType,
                                  long fileSize) {

        String bucket = ctx.getInitParameter("AWS_S3_BUCKET");
        AmazonS3 s3 = buildClient(ctx);

        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentType(contentType);
        metadata.setContentLength(fileSize);

        PutObjectRequest putRequest = new PutObjectRequest(bucket, s3Key, inputStream, metadata);
        s3.putObject(putRequest);
    }

    /**
     * Delete a file from S3.
     *
     * @param ctx   ServletContext
     * @param s3Key Object key stored in DB file_path column
     */
    public static void deleteFile(ServletContext ctx, String s3Key) {
        String bucket = ctx.getInitParameter("AWS_S3_BUCKET");
        AmazonS3 s3 = buildClient(ctx);
        s3.deleteObject(new DeleteObjectRequest(bucket, s3Key));
    }

    /**
     * Generate a pre-signed URL valid for the given number of minutes.
     *
     * @param ctx           ServletContext
     * @param s3Key         Object key
     * @param expiryMinutes How long the URL stays valid
     * @param inline        true = Content-Disposition inline (preview), false = attachment (download)
     * @return Pre-signed URL as String
     */
    public static String getPresignedUrl(ServletContext ctx,
                                         String s3Key,
                                         int expiryMinutes,
                                         boolean inline) {

        String bucket = ctx.getInitParameter("AWS_S3_BUCKET");
        AmazonS3 s3 = buildClient(ctx);

        Date expiry = new Date(System.currentTimeMillis() + (long) expiryMinutes * 60 * 1000);

        GeneratePresignedUrlRequest urlRequest =
                new GeneratePresignedUrlRequest(bucket, s3Key)
                        .withMethod(HttpMethod.GET)
                        .withExpiration(expiry);

        if (!inline) {
            // Force browser to download rather than display
            com.amazonaws.services.s3.model.ResponseHeaderOverrides overrides =
                    new com.amazonaws.services.s3.model.ResponseHeaderOverrides();
            overrides.setContentDisposition("attachment");
            urlRequest.setResponseHeaders(overrides);
        }

        URL url = s3.generatePresignedUrl(urlRequest);
        return url.toString();
    }
}
