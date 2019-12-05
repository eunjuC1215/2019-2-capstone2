package com.example.hyoja;

import android.util.Base64;

import java.security.Key;
import java.security.MessageDigest;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class AES {

    private static final String KEY = "안알려줌";
    private static final String IV = "안알려줌";
    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/CBC/PKCS5Padding";
    private  Cipher cipher;
    private Key key;
    private IvParameterSpec iv;

    public AES(){
        this.key = new SecretKeySpec(getHash("SHA-256", KEY), ALGORITHM);
        this.iv = new IvParameterSpec(getHash("MD5", IV));
        init();
    }
    private static byte[] getHash(final String algorithm, final String text){
        try{
            return getHash(algorithm, text.getBytes("UTF-8"));
        }catch (final Exception e){
            throw new RuntimeException(e.getMessage());
        }
    }

    private static byte[] getHash(final String algorithm, final byte[] data){
        try{
            final MessageDigest digest = MessageDigest.getInstance(algorithm);
            digest.update(data);
            return digest.digest();
        }catch (final Exception e){
            throw new RuntimeException(e.getMessage());
        }
    }

    private  void init(){
        try{
            cipher = Cipher.getInstance(TRANSFORMATION);
        }catch (final Exception e){
            throw new RuntimeException(e.getMessage());
        }
    }

    public String encrypt(final String str){
        try{
            return encrypt(str.getBytes("UTF-8"));
        }catch (final Exception e){
            throw new RuntimeException(e.getMessage());
        }
    }
    public String encrypt(final byte[] data){
        try{
            cipher.init(Cipher.ENCRYPT_MODE, key, iv);
            final byte[] encryptData = cipher.doFinal(data);
            return new String(Base64.encode(encryptData, Base64.DEFAULT), "UTF-8");
        }catch (final Exception e){
            throw new RuntimeException(e.getMessage());
        }
    }
}
