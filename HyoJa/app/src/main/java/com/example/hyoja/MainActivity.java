package com.example.hyoja;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class MainActivity extends AppCompatActivity {

    private Button scanQRBtn;
    private Button logout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        scanQRBtn = (Button) findViewById(R.id.scanQR);

        scanQRBtn.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                Intent intent = new Intent(MainActivity.this, ScanQR.class);
                startActivity(intent);
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
    }
}
