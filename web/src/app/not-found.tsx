// not-found error page

import React from 'react';

const NotFound: React.FC = () => {
  return (
    <div className="w-[1200px] flex flex-col items-center justify-center gap-[45px] max-w-full mq675:gap-[22px]">
      <div className="self-stretch flex flex-col items-center justify-center gap-[33px] max-w-full mq675:gap-[16px]">
        <div className="flex flex-row items-center justify-center py-0 px-[43px] box-border max-w-full mq750:pl-[21px] mq750:pr-[21px] mq750:box-border">
          <div className="w-[1200px] flex flex-col items-start justify-start gap-[45px] max-w-full mq675:gap-[22px]">
            <title>404 | サイト名</title>
            <h1 style={{ fontSize: '24px' }}>404 ページが見つかりません</h1>
            <p style={{ fontSize: '18px' }}>
              申し訳ありませんが、お探しのページは存在しません。
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NotFound;
