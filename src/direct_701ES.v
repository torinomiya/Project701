//Raspi :
//Volumio をインストールしておくと、16bit指定したときに　32fsのI2S信号を出す。
//この時は、Dataがずれているのだけを修正する。　
//`define RasPi
`define for501ES

//TODO: LRCKのカウントを行って、自動判別するとかしたい
`define CM6631_1fs	//謎のBCK = 128fs出しをしてくるので

module direct_701ES(
mck, aes3, ext_bck, ext_lrck, ext_data, bck, bck_701, lrck, lrck_701, data, data_701, APT_L, APT_R, HC74_Q, HC74_Q_inv
);

    input ext_bck;
    input ext_lrck;
    input ext_data;
    output bck;
    output bck_701;
    output lrck;
    output lrck_701;
    output data;
    output data_701;

    output APT_L;
    output APT_R;
    output HC74_Q;
    output HC74_Q_inv;

    //If external SPDI/F input.
    input mck; //device pin AH15 for develop board "but affect to another signal..
    input aes3;
    // wire bsync;
    // wire active;
    // aes3_rx aes3_rx_ins (mck, aes3, 0, data, bck, bsync, lrck, active);

    //外部からI2S注入する場合の確認用
    assign bck = ext_bck;
    assign lrck = ext_lrck;
    assign data = ext_data;

`ifdef RasPi
    //BCK / DATAはそのままスルー
    assign bck_701 = bck;
    assign data_701 = data;
    //16bitのI2Sが出力される為、BCK1周期分だけ遅らせる
    delay_1BCK I2S16_to_16LJ_ins (ext_lrck, ext_bck, lrck_701);
`elsif CM6631_1fs
	wire normal_bck;
	wire normal_lrck;
	wire normal_data;

    //通常のI2Sに変換
    CM6631_to_I2S64fs CM6631_to_I2S64fs_ins (ext_bck, ext_data, ext_lrck, normal_bck, normal_data, normal_lrck);

    // //test I2Sの変換がうまくいっているかどうかを確認する
	// assign bck_701 = normal_bck;
	// assign lrck_701 = normal_lrck;
	// assign data_701 = normal_data;
	
    //I2Sを16LJ に変換
    I2S_to_16LJ I2S_to_16LJ_ins (normal_bck, normal_data, normal_lrck, bck_701, data_701, lrck_701);
`else
    //I2Sを16LJ に変換
    I2S_to_16LJ I2S_to_16LJ_ins (ext_bck, ext_data, ext_lrck, bck_701, data_701, lrck_701);
`endif

`ifdef for501ES
    //501ES の場合、APT_L の場所にwckをだします
    output_501ES output_501ES_ins (bck_701, lrck_701, APT_L);
    assign APT_R = 0;
    assign HC74_Q = 0;
    assign HC74_Q_inv = 0;
`else
    //701ESで16LJ以外に必要な信号を生成
    output_701ES output_701ES_ins (bck_701, lrck_701, APT_L, APT_R, HC74_Q_inv, HC74_Q);
`endif

endmodule
