TITLE GUGUDAN Print
;	���α׷� �ۼ��� : 20150514 ��ǿ�
;	��� : �������� ����ϴ� �ڵ�
;	�Է� : 2~9 ������ ������ ǥ�� �Է����� �Է¹޴´�.
;	��� : �ش��ϴ� ������ k���� ��µ�.

INCLUDE Irvine32.inc

pressKey EQU <"Enter a digit(2~9): ", 0>	; ������ EQU Directive�κ��� �����Ͽ� �ۼ��Ͽ���.
.data
prompt BYTE pressKey		;	pressKey�� ���ڿ��� ������ ������ ���� �Է��� �ޱ� ���� ���ù����� ����Ѵ�.
num DWORD ?					;	�Է¹��� unsigned int�� �����ϱ� ���� ����
temp DWORD ?				;	�������� ���� �����ϱ� ���� �ӽ� ���� ����
new_line BYTE 0dh, 0ah, 0	;	new_line�� ����ϱ� ���� ���ڿ��̴�.
star BYTE " * ", 0			;	"*"�� ����ϱ� ���� ���ڿ�
equal BYTE " = ", 0			;	"="�� ����ϱ� ���� ���ڿ�

.code
main PROC
	mov edx, OFFSET prompt	;	help���Ͽ��� ���ڿ��� ����ϴ� ����� �����Ͽ���.
	call WriteString
	call ReadDec			;	ó���� ReadInt�� ������ +�� ��µǾ� unsigned integer�� �Է¹޴� ReadDec�� ���
	mov num, eax			;	������ �Էµ� ���� eax�� ����ǹǷ� �̸� num�� ����
	mov ecx, 9				;	�������� 9���� loop�� ���� ������ ecx�� 9�� ��

L1:
	mov temp, eax			;	eax�� ������ ������� ����ϱ� ���� ���������̹Ƿ� ��� temp�� �Űܵд�
	mov eax, num			;	num�� ����ؾ� �ϹǷ� eax�� num�� �Ű� ���
	call WriteDec
	mov eax, temp			;	temp�� ����� ������ ������� �ٽ� eax�� �ű�

	mov edx, OFFSET star
	call WriteString		;	star�� ����� " * "�� ���

	mov ebx, 10				;	9���� loop�� ���� ���� 1���� 9���� ��Ÿ�� ���ڸ� ���� ebx�� 10 ����
	sub ebx, ecx			;	10���� loop�� �� Ƚ���� ����
	mov temp, eax			;	WriteDec �Լ��� eax�� ����ϹǷ� eax(���� ���)�� temp�� �ű�� ebx�� ���
	mov eax, ebx
	call WriteDec

	mov edx, OFFSET equal	;	" = " ���ڿ�(equal)�� ���
	call WriteString

	mov eax, temp			;	temp�� ����Ǿ� �ִ� ���� ����� �ҷ��� ���
	call WriteDec

	add eax, num			;	���� �� loop�� ����� ������� ���
	mov edx, OFFSET new_line;	C���� "\n"�� ����ϴ� �Ͱ� ����
	call WriteString		;	
	loop L1
	exit
main ENDP
END main