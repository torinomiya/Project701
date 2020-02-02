//Raspi :
//Volumio をインストールしておくと、16bit指定したときに　32fsのI2S信号を出す。
//この時は、Dataがずれているのだけを修正する。　
//`define RasPi

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

    //外部からI2S注入
    assign bck = ext_bck;
    assign lrck = ext_lrck;
    assign data = ext_data;

`ifdef RasPi
    //BCK / DATAはそのままスルー
    assign bck_701 = bck;
    assign data_701 = data;
    //I2Sなので16LJにするためにLRCKをBCKいっこ分おくらすことだけやる
    I2S_to_16LJ64fs I2S_to_16LJ64fs_ins (lrck, bck, lrck_701);
`else
    //I2Sを 16LJ32fs に変換
    I2S_to_16LJ32fs I2S_to_16LJ32fs_ins (bck, data, lrck, bck_701, data_701, lrck_701);
`endif

    //701ESでI2S(16LJ32fs）以外に駆動用に必要な信号を生成
    output_701ES output_701ES_ins (bck_701, lrck_701, APT_L, APT_R, HC74_Q_inv, HC74_Q);

endmodule
