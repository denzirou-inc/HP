import clsx from 'clsx';

interface AnimationButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
}

const AnimationButton = ({
  children,
  variant = 'primary',
}: AnimationButtonProps) => {
  return (
    <button
      type="button"
      className={clsx(
        'animation-button inline-block py-4 px-8 text-center rounded-[50px] cursor-pointer text-base font-kosugi-maru tracking-wider',
        {
          'bg-sandybrown text-white animation-button-primary':
            variant === 'primary',
          'bg-darkslateblue text-white animation-button-secondary':
            variant === 'secondary',
        }
      )}
    >
      <span className="relative z-10">{children}</span>
    </button>
  );
};

export default AnimationButton;
