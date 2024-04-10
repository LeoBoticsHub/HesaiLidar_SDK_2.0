#include "hesai_lidar_sdk_gpu.cuh"
uint32_t last_frame_time;
uint32_t cur_frame_time;std::mutex mex_viewer;


//log info, display frame message
void lidarCallback(const LidarDecodedFrame<LidarPointXYZIRT>  &frame) {
  cur_frame_time = GetMicroTickCount();  
  if (cur_frame_time - last_frame_time > kMaxTimeInterval) {
    printf("Time between last frame and cur frame is: %d us\n", (cur_frame_time - last_frame_time));
  }
  last_frame_time = cur_frame_time;    
  printf("frame:%d points:%u packet:%d start time:%lf end time:%lf\n",frame.frame_index, frame.points_num, frame.packet_num, frame.points[0].timestamp, frame.points[frame.points_num - 1].timestamp) ;
}


int main(int argc, char *argv[])
{
  HesaiLidarSdkGpu<LidarPointXYZIRT> sample;
  DriverParam param;
  // assign param
  param.decoder_param.enable_parser_thread = false;
  param.input_param.source_type = DATA_FROM_LIDAR;
  param.input_param.pcap_path = "";
  param.input_param.correction_file_path = "";
  param.input_param.firetimes_path = "";

  param.input_param.device_ip_address = "192.168.123.20";
  param.input_param.ptc_port = 9347;
  param.input_param.udp_port = 2368;
  param.input_param.host_ip_address = "192.168.123.24";
  param.input_param.multicast_ip_address = "";



  //init lidar with param
  sample.Init(param);
  float socket_buffer = 262144000;
  sample.lidar_ptr_->source_->SetSocketBufferSize(socket_buffer);

  //assign callback fuction
  sample.RegRecvCallback(lidarCallback);

  //star process thread
  sample.Start();
  while (1)
  {
  
    std::this_thread::sleep_for(std::chrono::milliseconds(40));

  }
}