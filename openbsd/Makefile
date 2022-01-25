.PHONY: install
install:
	@echo "Installing blockor"
	@cp -Rv ../usr /
	@cp -Rv etc /
	@cp -Rv usr /
	@echo "Successfully installed"

.PHONY: uninstall
uninstall:
	@echo "Removing blockor"
	@rm -vf /usr/local/bin/blockor
	@rm -vf /usr/local/libexec/blockord.sh
	@rm -vf /etc/rc.d/blockord
	@rm -vf /usr/local/etc/blockor.conf
	@rm -rvf /usr/local/share/examples/blockor
	@echo "Successfully removed"
