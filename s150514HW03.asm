TITLE GUGUDAN Print
;	프로그램 작성자 : 20150514 김건우
;	기능 : 구구단을 출력하는 코드
;	입력 : 2~9 사이의 정수를 표준 입력으로 입력받는다.
;	출력 : 해당하는 구구단 k단이 출력됨.

INCLUDE Irvine32.inc

pressKey EQU <"Enter a digit(2~9): ", 0>	; 교과서 EQU Directive부분을 참고하여 작성하였다.
.data
prompt BYTE pressKey		;	pressKey를 문자열로 가지고 있으며 추후 입력을 받기 위한 지시문으로 사용한다.
num DWORD ?					;	입력받은 unsigned int를 저장하기 위해 선언
temp DWORD ?				;	레지스터 값을 저장하기 위한 임시 변수 선언
new_line BYTE 0dh, 0ah, 0	;	new_line을 출력하기 위한 문자열이다.
star BYTE " * ", 0			;	"*"를 출력하기 위한 문자열
equal BYTE " = ", 0			;	"="를 출력하기 위한 문자열

.code
main PROC
	mov edx, OFFSET prompt	;	help파일에서 문자열을 출력하는 방법을 참고하였다.
	call WriteString
	call ReadDec			;	처음엔 ReadInt로 했으나 +가 출력되어 unsigned integer를 입력받는 ReadDec를 사용
	mov num, eax			;	위에서 입력된 수는 eax에 저장되므로 이를 num에 저장
	mov ecx, 9				;	구구단은 9번의 loop를 돌기 때문에 ecx를 9로 둠

L1:
	mov temp, eax			;	eax는 곱셈의 결과값을 출력하기 위한 레지스터이므로 잠시 temp에 옮겨둔다
	mov eax, num			;	num을 출력해야 하므로 eax에 num을 옮겨 출력
	call WriteDec
	mov eax, temp			;	temp에 저장된 곱셈의 결과값을 다시 eax로 옮김

	mov edx, OFFSET star
	call WriteString		;	star에 저장된 " * "를 출력

	mov ebx, 10				;	9번의 loop를 도는 동안 1부터 9까지 나타낼 숫자를 위해 ebx에 10 저장
	sub ebx, ecx			;	10에서 loop를 돈 횟수를 차감
	mov temp, eax			;	WriteDec 함수는 eax를 출력하므로 eax(곱셈 결과)를 temp에 옮기고 ebx를 출력
	mov eax, ebx
	call WriteDec

	mov edx, OFFSET equal	;	" = " 문자열(equal)을 출력
	call WriteString

	mov eax, temp			;	temp에 저장되어 있던 곱셈 결과를 불러와 출력
	call WriteDec

	add eax, num			;	다음 번 loop에 출력할 결과값을 계산
	mov edx, OFFSET new_line;	C언어에서 "\n"을 출력하는 것과 같음
	call WriteString		;	
	loop L1
	exit
main ENDP
END main