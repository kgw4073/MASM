TITLE Polynomial
;	프로그램 작성자 : 20150514 김건우
;	기능 : 주어진 다항식 38*x1 + 47*x2 + 19*x3를 계산하기 위한 프로그램
;	입력 : CSE3030_PHW02_2019.inc를 데이터 파일로 저장한다. 과제 안내문의 예시에 따르면 x1=5, x2=-10, x3=20으로 각각 DWORD로 선언됨.
;	출력 : 예를 들어 위의 다항식에 예시 데이터를 입력하면 +100이 나와야 함.

INCLUDE Irvine32.inc
;	Irvine32 라이브러리를 포함시킨다.

INCLUDE CSE3030_PHW02_2019.inc
COMMENT @
라이브러리 속성을 정할 때 C:\Irvine으로 경로를 정했으므로 해당 경로에 데이터 파일을 저장시킨다.
@

.code
main PROC
	mov eax, 0
	add eax, x1	
	add eax, x2	
	add eax, x3		; eax = x1+x2+x3
	mov ebx, eax	; ebx = x1+x2+x3	ebx에 x1+x2+x3을 잠시 저장
	add eax, eax	; eax = 2*(x1+x2+x3)
	add eax, eax	; eax = 4*(x1+x2+x3)
	add eax, eax	; eax = 8*(x1+x2+x3)
	add eax, eax	; eax = 16*(x1+x2+x3)
	add eax, ebx	; eax = 17*(x1+x2+x3)
	add eax, ebx	; eax = 18*(x1+x2+x3)
	add eax, ebx	; eax = 19*(x1+x2+x3)
	add eax, eax	; eax = 38*(x1+x2+x3)
	mov ebx, eax	; ebx = 38*(x1+x2+x3)
	mov eax, x2		; eax = x2
	sub eax, x3		; eax = x2 - x3
	sub eax, x3		; eax = x2 - 2*x3
	mov edx, eax	; edx = x2 - 2*x3	edx에다가 x2 - 2*x3를 잠시 저장
	add eax, eax	; eax = 2*x2 - 4*x3
	add eax, eax	; eax = 4*x2 - 8*x3
	add eax, eax	; eax = 8*x2 - 16*x3
	add eax, edx	; eax = 9*x2 - 18*x3
	sub eax, x3		; eax = 9*x2 - 19*x3
	add eax, ebx	; eax = 38*(x1+x2+x3) + 9*x2 - 19*x3
	call WriteInt	; eax에 최종적으로 저장된 정수값을 출력
	exit
main ENDP
END main