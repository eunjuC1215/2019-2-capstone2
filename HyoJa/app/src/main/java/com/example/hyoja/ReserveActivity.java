package com.example.hyoja;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class ReserveActivity extends AppCompatActivity implements View.OnClickListener {

    ViewGroup layout;

    public static String seats ="++++++++ㅕㅑ/"
            +"__________/"
            +"000_00_000/"
            +"000_00_000/"
            +"____00____/"
            +"____00____/"
            +"000_00_000/"
            +"000_00_000/"
            +"____00____/"
            +"____00____/"
            +"000____000/"
            +"000____000/"
            +"____00____/"
            +"____00____/"
            +"000_00_000/"
            +"000_00_000/"
            +"____00____/"
            +"____00____/"
            +"000_00_000/"
            +"000_00_000/"
            +"__________/"
            +"--------ㅓㅏ/";

    List<TextView> seatViewList = new ArrayList<>();
    int seatSize = 100;
    int seatGaping = 10;

    int STATUS_AVAILABLE = 0;
    int STATUS_BOOKED = 1;
    int STATUS_RESERVED = 2;
    String selectedIds = "";

    Boolean isSelected = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_reserve);

        getSeatsData getSeatsData = new getSeatsData();
        getSeatsData.execute();
    }

    @Override
    public void onClick(final View v) {
        if(isSelected == false){
            if((int) v.getTag() == STATUS_AVAILABLE){
                final String seat_no = Integer.toString(v.getId());
                selectedIds = selectedIds + v.getId() + ", ";
                v.setBackgroundResource(R.drawable.ic_seats_selected);
                isSelected = true;

                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("예약 확인");
                builder.setMessage("Seat-" + v.getId() + " 예약 하시겠습니까");

                builder.setPositiveButton("예", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Toast.makeText(getApplicationContext(), "예약되었습니다.", Toast.LENGTH_SHORT).show();
                        Intent intent = new Intent(ReserveActivity.this, MainActivity.class);
                        sendReserveInfo send_reserve_info = new sendReserveInfo();
                        send_reserve_info.execute(seat_no);
                        finish();
                    }
                });

                builder.setNegativeButton("아니오", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        Toast.makeText(getApplicationContext(), "예약취소되었습니다.", Toast.LENGTH_SHORT).show();
                        selectedIds = selectedIds.replace(+v.getId() + ",", "");
                        v.setBackgroundResource(R.drawable.ic_seats_available);
                        isSelected = false;
                        finish();
                        startActivity(getIntent());
                    }
                });

                AlertDialog alertDialog = builder.create();
                alertDialog.show();
            } else if((int) v.getTag() == STATUS_BOOKED){
                Toast.makeText(this, "Seat " + v.getId() + " 예약되어있습니다.", Toast.LENGTH_SHORT).show();
            } else if ((int) v.getTag() == STATUS_RESERVED) {
                Toast.makeText(this, "Seat " + v.getId() + "은 이용이 불가합니다.", Toast.LENGTH_SHORT).show();
            }
        }else{
            if((int) v.getTag() == STATUS_AVAILABLE){
                if(selectedIds.contains(v.getId() + ",")){
                    selectedIds = selectedIds.replace(+v.getId() + ",", "");
                    v.setBackgroundResource(R.drawable.ic_seats_available);
                    isSelected = false;
                }
            }
        }
    }

    public void drawSeats(String s){
        layout = findViewById(R.id.layoutSeat);
        seats = "/" + seats;

        LinearLayout layoutSeat = new LinearLayout(ReserveActivity.this);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        layoutSeat.setOrientation(LinearLayout.VERTICAL);
        layoutSeat.setLayoutParams(params);
        layoutSeat.setPadding(8*seatGaping,8*seatGaping, 8*seatGaping, 8*seatGaping);
        layout.addView(layoutSeat);

        LinearLayout layout = null;
        int count = 0;

        for (int index = 0; index < seats.length(); index++) {
            if (seats.charAt(index) == '/') {
                layout = new LinearLayout(ReserveActivity.this);
                layout.setOrientation(LinearLayout.HORIZONTAL);
                layoutSeat.addView(layout);
            } else if (seats.charAt(index) == '0' && s.charAt(count) == '0') {
                count++;
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                view.setPadding(0, 0, 0, 2 * seatGaping);
                view.setId(count);
                view.setGravity(Gravity.CENTER);
                view.setBackgroundResource(R.drawable.ic_seats_available);
                view.setText(count + "");
                view.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 11);
                view.setTextColor(Color.BLACK);
                view.setTag(STATUS_AVAILABLE);
                layout.addView(view);
                seatViewList.add(view);
                view.setOnClickListener(ReserveActivity.this);
            } else if (seats.charAt(index) == '0' && s.charAt(count) == '1') {
                count++;
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                view.setPadding(0, 0, 0, 2 * seatGaping);
                view.setId(count);
                view.setGravity(Gravity.CENTER);
                view.setBackgroundResource(R.drawable.ic_seats_booked);
                view.setTextColor(Color.WHITE);
                view.setTag(STATUS_BOOKED);
                view.setText(count + "");
                view.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 11);
                layout.addView(view);
                seatViewList.add(view);
                view.setOnClickListener(ReserveActivity.this);
            } else if (seats.charAt(index) == '0' && s.charAt(count) == '2') {
                count++;
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                view.setPadding(0, 0, 0, 2 * seatGaping);
                view.setId(count);
                view.setGravity(Gravity.CENTER);
                view.setBackgroundResource(R.drawable.ic_seats_reserved);
                view.setText(count + "");
                view.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 11);
                view.setTextColor(Color.WHITE);
                view.setTag(STATUS_RESERVED);
                layout.addView(view);
                seatViewList.add(view);
                view.setOnClickListener(ReserveActivity.this);
            } else if (seats.charAt(index) == '_') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                view.setBackgroundColor(Color.TRANSPARENT);
                view.setText("");
                layout.addView(view);
            } else if (seats.charAt(index) == '+') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                //view.setBackgroundColor(Color.TRANSPARENT);
                view.setBackgroundResource(R.drawable.ic_wall_back);
                view.setText("");
                layout.addView(view);
            }
            else if (seats.charAt(index) == '-') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                //view.setBackgroundColor(Color.TRANSPARENT);
                view.setBackgroundResource(R.drawable.ic_wall_back);
                view.setText("");
                layout.addView(view);
            } else if (seats.charAt(index) == 'ㅓ') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                //view.setBackgroundColor(Color.TRANSPARENT);
                view.setBackgroundResource(R.drawable.ic_door_back_left);
                view.setText("");
                layout.addView(view);
            } else if (seats.charAt(index) == 'ㅏ') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                //view.setBackgroundColor(Color.TRANSPARENT);
                view.setBackgroundResource(R.drawable.ic_door_back_right);
                view.setText("");
                layout.addView(view);
            } else if (seats.charAt(index) == 'ㅕ') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                //view.setBackgroundColor(Color.TRANSPARENT);
                view.setBackgroundResource(R.drawable.ic_door_front_left);
                view.setText("");
                layout.addView(view);
            } else if (seats.charAt(index) == 'ㅑ') {
                TextView view = new TextView(ReserveActivity.this);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(seatSize, seatSize);
                layoutParams.setMargins(seatGaping, seatGaping, seatGaping, seatGaping);
                view.setLayoutParams(layoutParams);
                //view.setBackgroundColor(Color.TRANSPARENT);
                view.setBackgroundResource(R.drawable.ic_door_front_right);
                view.setText("");
                layout.addView(view);
            }
        }
    }

    public class sendReserveInfo extends AsyncTask<String, Void, String>{

        ProgressDialog progressDialog;
        String errorString;

        @Override
        protected void onPreExecute(){
            super.onPreExecute();
            progressDialog = ProgressDialog.show(ReserveActivity.this, "Please wait...", null, true, true);
        }

        @Override
        protected void onPostExecute(String s){
            super.onPostExecute(s);
            progressDialog.dismiss();
            if(s.equals("Success")){
                Intent intent = new Intent(ReserveActivity.this, MainActivity.class);
                startActivity(intent);
                finish();
            }else{
                Toast.makeText(ReserveActivity.this, s + "다른 사람이 먼저 예약했습니다.", Toast.LENGTH_LONG).show();
                startActivity(getIntent());
            }
        }

        @Override
        protected String doInBackground(String... params){
            SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);
            String loginID = auto.getString("ID", null);
            String seatNo = params[0];
            String server_url = "http://13.124.28.135/reserve.php";
            String postParameters = "student_no=" + loginID + "&&seat_no=" + seatNo + "&&reserve_opt=1";

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

    public class getSeatsData extends AsyncTask<String, Void, String>{
        ProgressDialog progressDialog;
        String errorString;
        @Override
        protected void onPreExecute(){
            super.onPreExecute();
            progressDialog = ProgressDialog.show(ReserveActivity.this, "Please wait...", null, true, true);

        }

        @Override
        protected String doInBackground(String... params) {

            SharedPreferences auto = getSharedPreferences("auto", Activity.MODE_PRIVATE);
            String loginID = auto.getString("ID", null);
            String server_url = "http://13.124.28.135/getSeatsData.php";
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
            if(s.equals("Exist")){
                Toast.makeText(ReserveActivity.this, "예약한 좌석이 있습니다.\n 예약확정을 해주세요", Toast.LENGTH_LONG).show();
                finish();
            }else{
                drawSeats(s);
            }
        }
    }
}
