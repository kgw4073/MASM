TITLE Redirection	;
;	���α׷� �ۼ��� : 20150514 ��ǿ�
;	���� : �� �࿡ ����� ���ڸ� �տ� �ִ� ���ڸ�ŭ �ݺ��ϴ� ���α׷�
;	�Է� : in.txt(�ݺ��� Ƚ���� ���ڿ��� ����ִ� ����)
;	��� : out.txt(������ ���ڰ� �ݺ��Ǿ� ����� ����)

INCLUDE Irvine32.inc

.stack 4096	; ���� ������ ����� ���̹Ƿ� ũ�⸦ ����

CR=0Dh	;	new_line
LF=0Ah

BUF_SIZE=20	;	null�� �����ϰ� �ִ� 20���� ���ڸ� ���� �� �����Ƿ� 
.data
	stdinHandle HANDLE ?
	stdoutHandle HANDLE ?
	inBuf BYTE BUF_SIZE DUP(?)
	bytesREAD DWORD ?
	outBuf BYTE BUF_SIZE DUP(?)
	bytesWRITE DWORD ?
	new_line BYTE 0Dh, 0Ah, 0	;	new_line ���ڿ�
	temp DWORD ?	;	temp�� temp_2�� ��� ecx�� �����ϱ� ���� �޸�
	temp_2 DWORD ?

.code

Read_a_Line PROC	
; Read_a_Line �Լ��� �����ڷ� �״�� ���
.data
Single_Buf__ BYTE ?
Byte_Read__ DWORD ?

.code
xor ecx, ecx
Read_Loop:
	push eax
	push ecx
	push edx
	INVOKE ReadFile, eax, offset Single_Buf__, 1, offset Byte_Read__, 0
	pop edx
	pop ecx
	pop eax
	cmp DWORD PTR Byte_Read__, 0
	je Read_End
	mov bl, Single_Buf__
	cmp bl, CR
		je Read_Loop
	cmp bl, LF
		je Read_End
	mov [edx], bl
	inc edx
	inc ecx
	jmp Read_Loop
Read_End:
	mov BYTE PTR [edx], 0
	ret
Read_a_Line ENDP

main PROC
	; ���� �� ���� HANDLE�� �����ϱ� ����
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

	
	Write_to_out:
		; Write_to_out�� out.txt�� �����ϱ� ���� ���

		mov eax, stdinHandle
		mov edx, OFFSET inBuf	; Read_a_Line�� input���� eax�� HANDLE, edx�� ���� ���ڿ��� ������ OFFSET�� �ʿ��ϴ�.
		INVOKE Read_a_Line
		
		cmp ecx, 2
		jle Exit_P	;	���� ������ ������ 2�� �����̸� �����Ѵ�.

		sub edx, ecx	; Read_a_Line�� ������ �� edx�� ���ڿ��� ���� ����Ű�� �ȴ�. ���� ���ڿ��� �������� ���� ���ؼ� ���� ���� �� ��ŭ ���ش�.
		mov ebx, 0
		mov bl, [edx]	; ebx�� ���ڿ��� ó��, ��, ���ڸ� ��Ÿ���� ���ڸ� �����Ѵ�.
		sub ebx, 30h	; �ƽ�Ű���ڷ� ��Ÿ�� ���� ��¥ ���ڷ� �ٲٱ� ���� 30h�� ���ش�.
		mov temp, ebx	; ebx���� �� ���� ó�� ��Ÿ���� ���ڰ� ����ȴ�. �̸� temp�� �����Ѵ�.

		sub ecx, 2	; ���� ������ ���� �� ù �� ���ڴ� �ǹ̰� ����.(���ڿ� ����) ���� 2�� ���ش�.
		add edx, 2	; �ݺ��� ���ڿ� ���� �� ��° ���̹Ƿ� edx�� 2�� �����ش�.

		cmp ebx, 1	; ebx�� 1���� �۰ų�, 9���� ũ��, (��, ���ڰ� �ƴϸ�) �����Ѵ�.
		jl Exit_P
		cmp ebx, 9
		jg Exit_P

		NEXT_LINE:
			;	NEXT_LINE�� ������ �� ���� ���� �Ǵ� �����̴�.
			push ecx	; ù ��° ������ ecx�� �����ϱ� ���� ecx�� push
			mov ecx, temp	;	temp���� ������ ������ �� ���� ù ��° ���ڰ� ����Ǿ� �ִ�.

			Each_Character:	; �� ��° ������ ���� �� ���ڿ� ���� temp����ŭ �ݺ��Ѵ�.
				pushad 	; pushad�� �� ������ WriteFile�� �ϸ� ���������� ���� �ٲ�� ������ �� ���� �����ϱ� ���� ������ �̿��Ͽ���.
				INVOKE WriteFile, stdoutHandle, edx, 1, 0, 0
				popad
				loop Each_Character

			add edx, 1	; edx�� ���� ���ڸ� ����Ű�� �ϱ� ���� 1�� ������.
			pop ecx	; �����ߴ� ù ��° ������ ecx�� pop�Ѵ�.
			loop NEXT_LINE
		
		;	���� �� ���� �� ���� ����� ���±� ������ ���� ���ο� ��Ÿ���� ���� new_line�� ����ϴ� �ڵ��̴�. �ٽ� Write_to_out ����� ���� �� �̻��� ���ڰ� ���� ������ �ݺ��Ѵ�.
		mov edx, OFFSET new_line	
		INVOKE WriteFile, stdoutHandle, edx, 2, 0, 0
		jmp Write_to_out
		
	Exit_P:
		exit
main ENDP
END MAIN