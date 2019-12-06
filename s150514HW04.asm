TITLE BUGHOUSE
;	���α׷� �ۼ��� : 20150514 ��ǿ�
;	��� : �־��� ��ġ�� ������ �� ���� ��� �ִ��� ����.
;	�Է� : R, C (��� ��) ��ǥ
;	��� : �־��� ��ǥ�� �ִ� ���� ��

INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter R: ", 0							;	��� ���� �Է¹ޱ� ���� ���ڿ�
prompt2 BYTE "Enter C: ", 0							;
column_num = 10										;	���� ������ Equal-Sign Directive�� ���� ����
H DWORD 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 120 DUP(?)	;	H �迭�� ���Ҵ� 130���̰� ù 10���� ���Ҵ� �˷��� ������ ���Ŀ��� ����ؾ� �ϹǷ� DUP�� ���� ���� 
Ro DWORD ?											;	��� ���� �ε����� �����ϱ� ���� ����
Co DWORD ?

.code
main PROC
	mov edx, OFFSET prompt1			;	19~26���� Ro�� Co�� Ž���� ��� ���� �ε����� �Է¹ޱ� ���� �ڵ�
	call WriteString
	call ReadDec
	mov RO, eax
	mov edx, OFFSET prompt2
	call WriteString
	call ReadDec
	mov CO, eax

	mov ecx, 12						;	ù ��° ������ �� �ι� ���� ������ ����� ������ 120���� ���Ҹ� ä�� ���̴�.
	mov edi, 0						;	edi�� H�κ��� ������ OFFSET�� �����ϱ� ����
	L1:
		mov esi, OFFSET H			;	esi�� H�� OFFSET ���� ���� 
		add esi, edi				;	H�� OFFSET ���� edi�� ���Ͽ� esi�� ����Ű�� ���Ҵ� ���ؾ� �� ����(��, ���� ��) 
		mov eax, [esi]
		mov ebx, ecx				;	�� �࿡ ���ؼ�, ������ �� �� �� ���� ����ϰ� �����ؾ� �ϱ� ������ ���� ecx�� �ӽ� ����
		mov ecx, column_num			;	���� ���� ������ ecx�� �Ҵ�
		add edi, TYPE H*column_num	;	����ؾ� �� ���Ҵ� ���� ���̹Ƿ� ���� ���� OFFSET�� edi�� ����
		L2:
			mov H[edi], eax			;	���� ���� ���� �࿡���� �ش� �������� ���̹Ƿ�
			add edi, TYPE H			;	���� ������ OFFSET�� ���� TYPE H�� ����
			add esi, TYPE H			;	���� ���� ���� OFFSET�� TYPE H�� �����־�� ��
			add eax, [esi]			;	���� esi��(���� ���� ����)���� eax�� �����ְ� ������ ���� H[edi]�� ����
			loop L2

		mov ecx, ebx				;	�� ��° ������ �������Ƿ� ebx�� �����ߴ� ù ��° ���� Ƚ���� �ҷ���
		sub edi, TYPE H*column_num	;	edi���� TYPE H*10�� ���ִ� ������ ���� edi�� ���ؾ� �� �� ���� ���� ����Ű�Ƿ� ���� ������ �ٲ��־�� �ϱ� �����̴�.
		loop L1

	mov ecx, Ro						;	�Է¹��� ��� ���� row-major-order�� ����ϱ� ���� �۾��̴�.
	mov eax, 0

	L3:
		add eax, TYPE H*column_num	;	���� ����*TYPE H*Ro�� ����ϱ� ���� �����̴�.
		loop L3

	mov ebx, eax					;	ebx�� ������� ���� �ּҸ� �ű��.
	sub ebx, TYPE H					;	ebx���� TYPE H�� �� �� ���� ������ Co�� 1�� ���� ���� �����̴�. Co�� 1�� ������ TYPE H�� ������ �ʴ� ���°� �Ǿ�� �ϱ� ����.
	mov ecx, Co						;	Co��ŭ ������ ���� TYPE H�� ���ذ�. ���� 1�� ������ �̹� ������ TYPE H�� ���־��� ������ �� ���°� �ȴ�.
	L4:
		add ebx, TYPE H
		loop L4

	mov edi, ebx					;	���������� ebx���� row-major-order�� ����� OFFSET���� ����Ǿ� �ִ�. ���� edi�� �ű�� H[edi]�� �ϸ� �ش� ��ġ�� ���� ���� ���´�.
	mov eax, H[edi]
	call WriteDec
	exit
main ENDP
END main