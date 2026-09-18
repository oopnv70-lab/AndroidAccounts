package com.rosan.accounts.data.common.utils

import android.content.pm.UserInfo
import android.os.IUserManager
import android.util.Log

/**
 * Kotlin compatibility layer. Pure addition, original logic untouched.
 *
 * AOSP IUserManager.getUsers AIDL signature differs across branches:
 *   android15-release / android16-release : getUsers(boolean, boolean, boolean)
 *   android17-release                     : getUsers(boolean)
 *   master / HEAD                         : getUsers(boolean, boolean, boolean)
 *
 * So we try each signature one by one instead of hard-coding SDK_INT checks.
 */
object UserManagerCompat {

    private const val TAG = "UserManagerCompat"

    fun getUsersWithFallback(userManager: IUserManager): List<UserInfo> {
        var lastError: Throwable? = null

        // (1) original: three booleans (Android 11 ~ 16 / AOSP master)
        try {
            return userManager.getUsers(false, false, false)
        } catch (t: Throwable) {
            lastError = t
            Log.w(TAG, "getUsers(ZZZ) failed, trying next: " + t.javaClass.simpleName + ": " + t.message)
        }

        // (2) new branch: single boolean (Android 17 / Honor MagicOS 11)
        try {
            return userManager.getUsers(false)
        } catch (t: Throwable) {
            lastError = t
            Log.w(TAG, "getUsers(Z) failed, trying next: " + t.javaClass.simpleName + ": " + t.message)
        }

        // (3) fallback variant
        try {
            return userManager.getUsers(true, false, false)
        } catch (t: Throwable) {
            lastError = t
            Log.w(TAG, "getUsers(Z,Z,Z) variant failed: " + t.javaClass.simpleName + ": " + t.message)
        }

        throw IllegalStateException(
            "IUserManager.getUsers: no compatible signature found on this device (SDK_INT=" +
                android.os.Build.VERSION.SDK_INT + ")",
            lastError
        )
    }
}