package com.example.hyoja;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.CountDownTimer;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.view.ViewDebug;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import org.w3c.dom.Text;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity {

    private Button scanQRBtn, logout, reserve, reserveCancle;
    private TextView seatNo, time;
    public TimerTask timer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        seatNo = findViewById(R.id.seatNo);
        isReserve isreserve = new isReserve();
        isreserve.execute();

        time = findViewById(R.id.timeInfo);
        timer = null;

        scanQRBtn = (Button) findViewById(R.id.scanQR);

        scanQRBtn.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                if(seatNo.getText() == "--"){
                    Toast.makeText(MainActivity.this, "예약된 좌석이 없습니다", Toast.LENGTH_SHORT).show();
                } else{
                    Intent intent = new Intent(MainActivity.this, ScanQR.class);
                    startActivity(intent);
                }
            }
        });

        logout = findViewById(R.id.logout);
        logout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);
                SharedPreferences.Editor editor = auto.edit();

                editor.clear();
                editor.commit();

                Intent intent = new Intent(MainActivity.this, LoginActivity.class);
                startActivity(intent);
                finish();
            }
        });

        reserve = findViewById(R.id.reserve);
        reserve.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, ReserveActivity.class);
                startActivity(intent);

            }
        });

        reserveCancle = findViewById(R.id.reserveCancle);
        reserveCancle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(seatNo.getText() == "--"){
                    Toast.makeText(MainActivity.this, "예약된 좌석이 없습니다", Toast.LENGTH_SHORT).show();
                }else {
                    sendReserveInfo send_reserve_info = new sendReserveInfo();
                    send_reserve_info.execute();
                    seatNo.setText("--");
                    time.setText("--:--");
                }
            }
        });
    }

    public class isReserve extends AsyncTask<String, Void, String> {
        ProgressDialog progressDialog;
        String errorString;

        @Override
        protected void onPreExecute(){
            super.onPreExecute();
            progressDialog = ProgressDialog.show(MainActivity.this, "Please wait...", null, true, true);
        }

        @Override
        protected String doInBackground(String... params){
            SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);
            String loginID = auto.getString("ID", null);
            String server_url = "http://13.124.28.135/isReserve.php";
            String postParameters = "student_no=" + loginID;

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

        @Override
        protected void onPostExecute(String s){
            super.onPostExecute(s);
            progressDialog.dismiss();

            if(s.equals("0")){
                seatNo.setText("--");
                time.setText("--:--");
            }else {
                String[] str = s.split("_");
                seatNo.setText(str[0]);
                long now = System.currentTimeMillis();
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                Date nowT = new Date(now);
                String nowTime = sdf.format(nowT);

                long st = getSeconds(str[1]);
                long ct = getSeconds(nowTime);
                long t = (300 - (ct - st))*1000;

                //timer = new Timer();
                timer = new Timer(t);
                timer.run();
            }
        }
    }

    public long getSeconds(String s){
        String[] date = s.split(" ");
        String[] time = date[1].split(":");
        return Long.parseLong(time[0])*3600 + Long.parseLong(time[1])*60 + Long.parseLong(time[2]);
    }

    public class Timer extends TimerTask{

        public long t;
        Timer(long time){
            t = time;
        }
        @Override
        public void run() {
            CountDownTimer countDownTimer = new CountDownTimer(t, 1000) {
                @Override
                public void onTick(long millisUntilFinished) {
                    if(seatNo.getText() == "--"){
                        Timer.this.cancel();
                    }else{
                        int m = (int)millisUntilFinished / 60000;
                        int s = ((int)millisUntilFinished - m*60000)/1000;
                        time.setText(m+":"+s);
                    }
                }

                @Override
                public void onFinish() {
                    seatNo.setText("--");
                    time.setText("--:--");
                    sendReserveInfo sendReserveInfo = new sendReserveInfo();
                    sendReserveInfo.execute();
                }
            };
            countDownTimer.start();
        }

    }

    public class sendReserveInfo extends AsyncTask<String, Void, String> {

        ProgressDialog progressDialog;
        String errorString;

        @Override
        protected void onPreExecute(){
            super.onPreExecute();
            progressDialog = ProgressDialog.show(MainActivity.this, "Please wait...", null, true, true);
        }

        @Override
        protected void onPostExecute(String s){
            super.onPostExecute(s);
            progressDialog.dismiss();
            if(s.equals("Success")){
                Toast.makeText(MainActivity.this, "예약이 취소되었습니다.", Toast.LENGTH_SHORT).show();
            }else{
                Toast.makeText(MainActivity.this, "ERROR", Toast.LENGTH_SHORT).show();
            }
        }

        @Override
        protected String doInBackground(String... params){
            SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);
            String loginID = auto.getString("ID", null);
            String server_url = "http://13.124.28.135/reserve.php";
            String postParameters = "student_no=" + loginID + "&&reserve_opt=0";

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
