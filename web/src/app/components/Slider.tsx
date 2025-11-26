'use client';
import Image from 'next/image';
import { Autoplay, Navigation, Pagination } from 'swiper/modules';
import { Swiper, SwiperSlide } from 'swiper/react';
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/pagination';

interface Slide {
  id: number;
  imageUrl: string;
}

interface SliderProps {
  slides: Slide[];
}

export default function Slider({ slides }: SliderProps) {
  return (
    <Swiper
      modules={[Autoplay, Navigation, Pagination]}
      centeredSlides={true}
      speed={1200}
      loop={true}
      autoplay={{
        delay: 3000,
        disableOnInteraction: false,
      }}
      navigation
      pagination={{ clickable: true }}
      className="h-[600px] w-full mq450:h-[300px]"
    >
      {slides.map((slide) => (
        <SwiperSlide key={slide.id}>
          <Image
            src={slide.imageUrl}
            alt={`Slide ${slide.id}`}
            width={1920}
            height={1080}
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
            priority
          />
        </SwiperSlide>
      ))}
    </Swiper>
  );
}
