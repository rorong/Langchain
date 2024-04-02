class OpenAiController < ApplicationController
  
  def home
    @uuid = SecureRandom.uuid
  end
  
  def create_image
    client = OpenAI::Client.new
    response = client.images.generate(parameters: { prompt: open_ai_params[:prompt], size: "512x512" })
    generated_image = response.dig("data", 0, "url")
    uuid = open_ai_params[:uuid]
    Turbo::StreamsChannel.broadcast_update_to("channel_#{uuid}",
                                              target: 'ai_output_image',
                                              partial: 'open_ai/image',
                                              locals: { generated_image: })
  end
  
  private

  def open_ai_params
    params.require(:create_image).permit(:prompt, :ai_model, :uuid)
  end
end
