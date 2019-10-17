package com.example.hyoja;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class LoginActivity extends AppCompatActivity {
    private EditText EditText_id, EditText_pw;
    private CheckBox autoLogin;
    String loginID, loginPW;
    Boolean autologin_check;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        EditText_id = findViewById(R.id.idText);
        EditText_pw = findViewById(R.id.passwordText);
        autoLogin = findViewById(R.id.autoLogin);

        SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);

        loginID = auto.getString("ID", null);
        loginPW = auto.getString("PW", null);

        if(loginID != null && loginPW != null){
            EditText_id.setText(loginID);
            EditText_pw.setText(loginPW);

            Check check = new Check();
            check.execute(EditText_id.getText().toString(), EditText_pw.getText().toString());
        }

        Button loginButton = findViewById(R.id.loginButton);

        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent loginIntent = new Intent(LoginActivity.this, MainActivity.class);
                loginIntent.putExtra("student_no",loginID);
                LoginActivity.this.startActivity(loginIntent);
                /*
                if(autoLogin.isChecked()){
                    autologin_check = true;
                }else{
                    autologin_check = false;
                }
                Check check = new Check();
                check.execute(EditText_id.getText().toString(), EditText_pw.getText().toString());
                */
            }
        });

        TextView registerButton = findViewById(R.id.registerButton);

        registerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent registerIntent = new Intent(LoginActivity.this, RegisterActivity.class);
                LoginActivity.this.startActivity(registerIntent);
            }
        });
    }

    private class Check extends AsyncTask<String, Void, String>{
        ProgressDialog progressDialog;
        String errorString = null;

        @Override
        protected void onPreExecute(){
            super.onPreExecute();
            progressDialog = ProgressDialog.show(LoginActivity.this, "Please wait...", null, true, true);
        }

        @Override
        protected void onPostExecute(String s) {
            super.onPostExecute(s);
            progressDialog.dismiss();
            Intent intent = new Intent(LoginActivity.this, MainActivity.class);

            if(s.equals("Success")){
                if(loginID == null && loginPW == null && autologin_check){
                    SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);
                    SharedPreferences.Editor editor = auto.edit();

                    editor.putString("ID", EditText_id.getText().toString());
                    editor.putString("PW", EditText_pw.getText().toString());
                    editor.commit();
                }
                startActivity(intent);
                Toast.makeText(getApplicationContext(), "로그인 성공", Toast.LENGTH_LONG).show();
            }else{
                Toast.makeText(getApplicationContext(), "로그인 실패", Toast.LENGTH_LONG).show();
            }
        }

        @Override
        protected String doInBackground(String... params){
            AES aes = new AES();
            String id = params[0];
            String pw = aes.encrypt(params[1]);


            String server_url = "http://13.124.28.135/check.php";
            String postParameters = "id=" + id + "&pw=" + pw;

            try{
                URL url = new URL(server_url);
                HttpURLConnection httpURLConnection = (HttpURLConnection) url.openConnection();

                httpURLConnection.setReadTimeout(5000);
                httpURLConnection.setConnectTimeout(5000);
                httpURLConnection.setRequestMethod("POST");
                httpURLConnection.setDoInput(true);
                httpURLConnection.connect();

                OutputStream outputStream = httpURLConnection.getOutputStream();
                outputStream.write(postParameters.getBytes("UTF-8"));
                outputStream.flush();
                outputStream.close();

                int responseStatusCode = httpURLConnection.getResponseCode();

                InputStream inputStream;
                if(responseStatusCode == httpURLConnection.HTTP_OK){
                    inputStream = httpURLConnection.getInputStream();
                }else{
                    inputStream = httpURLConnection.getErrorStream();
                }

                InputStreamReader inputStreamReader = new InputStreamReader(inputStream, "UTF-8");
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);

                StringBuilder sb = new StringBuilder();
                String line;

                while((line = bufferedReader.readLine()) != null){
                    sb.append(line);
                }

                bufferedReader.close();

                return sb.toString().trim();
            }catch (Exception e){
                errorString = e.toString();
                return null;
            }
        }
    }

}