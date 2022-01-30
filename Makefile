.PHONY: install
install:
	@echo "Installing blockor"
	@if [ `uname -s | tr 'A-Z' 'a-z'` = "openbsd" ]; then \
		cp -Rv openbsd/usr / ; \
		cp -Rv openbsd/etc / ; \
	else \
		cp -Rv freebsd/usr / ; \
	fi
	@cp -Rv usr /
	@echo "Successfully installed"

.PHONY: uninstall
uninstall:
	@echo "Removing blockor"
	@if [ `uname -s | tr 'A-Z' 'a-z'` = "openbsd" ]; then \
		rm -vf /etc/rc.d/blockord ; \
	else \
		rm -vf /usr/local/etc/rc.d/blockord ; \
	fi
	@rm -vf /usr/local/bin/blockor
	@rm -vf /usr/local/libexec/blockord.sh
	@rm -vf /usr/local/etc/blockor.conf
	@rm -vf /usr/local/man/man8/blockor.8.gz
	@rm -rvf /usr/local/share/examples/blockor
	@echo "Successfully removed"